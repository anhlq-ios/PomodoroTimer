import Foundation
import SwiftUI

@MainActor
class TimerViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var timeRemaining: TimeInterval
    @Published var isRunning = false
    @Published var currentMode: TimerMode = .work
    @Published var completedPomodoros = 0
    @Published var notificationPermissionGranted = false
    @Published var sessions: [PomodoroSession] = []

    @Published var workDuration: Int {
        didSet {
            storage.set(workDuration, forKey: Keys.workDuration)
            if currentMode == .work && !isRunning { timeRemaining = Double(workDuration * 60) }
        }
    }

    @Published var shortBreakDuration: Int {
        didSet {
            storage.set(shortBreakDuration, forKey: Keys.shortBreakDuration)
            if currentMode == .shortBreak && !isRunning { timeRemaining = Double(shortBreakDuration * 60) }
        }
    }

    @Published var longBreakDuration: Int {
        didSet {
            storage.set(longBreakDuration, forKey: Keys.longBreakDuration)
            if currentMode == .longBreak && !isRunning { timeRemaining = Double(longBreakDuration * 60) }
        }
    }

    @Published var longBreakInterval: Int {
        didSet { storage.set(longBreakInterval, forKey: Keys.longBreakInterval) }
    }

    // MARK: - Dependencies

    private let storage: StorageProtocol
    private let dateProvider: DateProviderProtocol
    private let notificationService: NotificationServiceProtocol
    private var soundService: SoundServiceProtocol

    // MARK: - Sound Settings

    var selectedSound: SoundOption {
        get { soundService.selectedSound }
        set {
            soundService.selectedSound = newValue
            objectWillChange.send()
        }
    }

    func previewSound(_ sound: SoundOption) {
        soundService.playPreview(sound: sound)
    }

    private var timer: Timer?

    // MARK: - Constants

    private enum Keys {
        static let workDuration = "workDuration"
        static let shortBreakDuration = "shortBreakDuration"
        static let longBreakDuration = "longBreakDuration"
        static let longBreakInterval = "longBreakInterval"
        static let sessions = "pomodoroSessions"
    }

    // MARK: - Initialization

    init(
        storage: StorageProtocol = UserDefaults.standard,
        dateProvider: DateProviderProtocol = SystemDateProvider(),
        notificationService: NotificationServiceProtocol = SystemNotificationService(),
        soundService: SoundServiceProtocol = SoundManager.shared
    ) {
        self.storage = storage
        self.dateProvider = dateProvider
        self.notificationService = notificationService
        self.soundService = soundService

        self.workDuration = storage.integer(forKey: Keys.workDuration) ?? 25
        self.shortBreakDuration = storage.integer(forKey: Keys.shortBreakDuration) ?? 5
        self.longBreakDuration = storage.integer(forKey: Keys.longBreakDuration) ?? 15
        self.longBreakInterval = storage.integer(forKey: Keys.longBreakInterval) ?? 4
        self.timeRemaining = Double((storage.integer(forKey: Keys.workDuration) ?? 25) * 60)
        self.sessions = Self.loadSessions(from: storage)
        checkNotificationPermission()
    }

    // MARK: - Computed Properties

    var progress: Double {
        1 - (timeRemaining / durationFor(currentMode))
    }

    var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Statistics

    var todayCount: Int {
        let calendar = dateProvider.calendar
        let today = dateProvider.now
        return sessions.filter { calendar.isDate($0.date, inSameDayAs: today) && $0.mode == TimerMode.work.rawValue }.count
    }

    var weekCount: Int {
        let calendar = dateProvider.calendar
        let now = dateProvider.now
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        return sessions.filter { $0.date >= weekAgo && $0.mode == TimerMode.work.rawValue }.count
    }

    var totalCount: Int {
        sessions.filter { $0.mode == TimerMode.work.rawValue }.count
    }

    var weeklyStats: [DailyStat] {
        let calendar = dateProvider.calendar
        let now = dateProvider.now
        var stats: [DailyStat] = []

        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            let startOfDay = calendar.startOfDay(for: date)
            guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { continue }

            let count = sessions.filter {
                $0.date >= startOfDay && $0.date < endOfDay && $0.mode == TimerMode.work.rawValue
            }.count

            stats.append(DailyStat(date: date, count: count))
        }

        return stats
    }

    var totalFocusTimeString: String {
        let totalMinutes = totalCount * workDuration
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) min"
        }
    }

    // MARK: - Timer Controls

    func startPause() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }

    func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        pause()
        timeRemaining = durationFor(currentMode)
    }

    func switchMode(_ mode: TimerMode) {
        pause()
        currentMode = mode
        timeRemaining = durationFor(mode)
    }

    /// Simulate a timer tick - exposed for testing
    func tick() {
        guard timeRemaining > 0 else {
            timerComplete()
            return
        }
        timeRemaining -= 1
    }

    // MARK: - Settings

    func durationFor(_ mode: TimerMode) -> TimeInterval {
        switch mode {
        case .work: return Double(workDuration * 60)
        case .shortBreak: return Double(shortBreakDuration * 60)
        case .longBreak: return Double(longBreakDuration * 60)
        }
    }

    func resetToDefaults() {
        workDuration = 25
        shortBreakDuration = 5
        longBreakDuration = 15
        longBreakInterval = 4
        reset()
    }

    // MARK: - Sessions

    func recordSession(mode: TimerMode) {
        let session = PomodoroSession(mode: mode, date: dateProvider.now)
        sessions.append(session)
        saveSessions()
    }

    func clearAllSessions() {
        sessions.removeAll()
        completedPomodoros = 0
        saveSessions()
    }

    // MARK: - Notifications

    func requestNotificationPermission() {
        notificationService.requestAuthorization { [weak self] granted in
            Task { @MainActor in
                self?.notificationPermissionGranted = granted
            }
        }
    }

    // MARK: - Private Methods

    private func timerComplete() {
        pause()
        soundService.playCompletionSound()
        scheduleCompletionNotification()
        recordSession(mode: currentMode)

        if currentMode == .work {
            completedPomodoros += 1

            if completedPomodoros % longBreakInterval == 0 {
                switchMode(.longBreak)
            } else {
                switchMode(.shortBreak)
            }
        } else {
            switchMode(.work)
        }
    }

    private func checkNotificationPermission() {
        notificationService.checkAuthorizationStatus { [weak self] authorized in
            Task { @MainActor in
                self?.notificationPermissionGranted = authorized
            }
        }
    }

    private func scheduleCompletionNotification() {
        guard notificationPermissionGranted else { return }

        let (title, body): (String, String) = {
            switch currentMode {
            case .work:
                return ("Focus Session Complete!", "Great work! Time for a break.")
            case .shortBreak:
                return ("Break Over", "Ready to focus again?")
            case .longBreak:
                return ("Long Break Over", "Feeling refreshed? Let's get back to work!")
            }
        }()

        notificationService.scheduleNotification(title: title, body: body)
    }

    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            storage.set(encoded, forKey: Keys.sessions)
        }
    }

    private static func loadSessions(from storage: StorageProtocol) -> [PomodoroSession] {
        guard let data = storage.data(forKey: Keys.sessions),
              let decoded = try? JSONDecoder().decode([PomodoroSession].self, from: data) else {
            return []
        }
        return decoded
    }
}
