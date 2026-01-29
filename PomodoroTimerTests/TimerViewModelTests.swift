import XCTest
@testable import PomodoroTimer

@MainActor
final class TimerViewModelTests: XCTestCase {

    var storage: MockStorage!
    var dateProvider: MockDateProvider!
    var notificationService: MockNotificationService!
    var soundService: MockSoundService!
    var sut: TimerViewModel!

    override func setUp() async throws {
        storage = MockStorage()
        dateProvider = MockDateProvider()
        notificationService = MockNotificationService()
        soundService = MockSoundService()

        sut = TimerViewModel(
            storage: storage,
            dateProvider: dateProvider,
            notificationService: notificationService,
            soundService: soundService
        )
    }

    override func tearDown() async throws {
        sut = nil
        storage = nil
        dateProvider = nil
        notificationService = nil
        soundService = nil
    }

    // MARK: - Initialization Tests

    func testInitWithDefaultValues() {
        XCTAssertEqual(sut.workDuration, 25)
        XCTAssertEqual(sut.shortBreakDuration, 5)
        XCTAssertEqual(sut.longBreakDuration, 15)
        XCTAssertEqual(sut.longBreakInterval, 4)
        XCTAssertEqual(sut.timeRemaining, 25 * 60)
        XCTAssertEqual(sut.currentMode, .work)
        XCTAssertFalse(sut.isRunning)
    }

    func testInitLoadsStoredValues() {
        storage.set(30, forKey: "workDuration")
        storage.set(10, forKey: "shortBreakDuration")
        storage.set(20, forKey: "longBreakDuration")
        storage.set(6, forKey: "longBreakInterval")

        let viewModel = TimerViewModel(
            storage: storage,
            dateProvider: dateProvider,
            notificationService: notificationService,
            soundService: soundService
        )

        XCTAssertEqual(viewModel.workDuration, 30)
        XCTAssertEqual(viewModel.shortBreakDuration, 10)
        XCTAssertEqual(viewModel.longBreakDuration, 20)
        XCTAssertEqual(viewModel.longBreakInterval, 6)
    }

    // MARK: - Timer Control Tests

    func testStartSetsIsRunningToTrue() {
        sut.start()
        XCTAssertTrue(sut.isRunning)
        sut.pause() // Clean up timer
    }

    func testPauseSetsIsRunningToFalse() {
        sut.start()
        sut.pause()
        XCTAssertFalse(sut.isRunning)
    }

    func testStartPauseToggles() {
        XCTAssertFalse(sut.isRunning)

        sut.startPause()
        XCTAssertTrue(sut.isRunning)

        sut.startPause()
        XCTAssertFalse(sut.isRunning)
    }

    func testResetRestoresFullDuration() {
        sut.timeRemaining = 100
        sut.reset()
        XCTAssertEqual(sut.timeRemaining, 25 * 60)
    }

    func testTickDecrementsTimeRemaining() {
        let initialTime = sut.timeRemaining
        sut.tick()
        XCTAssertEqual(sut.timeRemaining, initialTime - 1)
    }

    func testTickCompletesTimerWhenTimeReachesZero() {
        sut.timeRemaining = 1
        sut.tick() // time becomes 0
        sut.tick() // triggers completion

        XCTAssertEqual(sut.currentMode, .shortBreak)
        XCTAssertEqual(sut.completedPomodoros, 1)
        XCTAssertTrue(soundService.playCompletionSoundCalled)
    }

    // MARK: - Mode Switching Tests

    func testSwitchModeChangesCurrentMode() {
        sut.switchMode(.shortBreak)
        XCTAssertEqual(sut.currentMode, .shortBreak)
        XCTAssertEqual(sut.timeRemaining, sut.durationFor(.shortBreak))
    }

    func testSwitchModePausesTimer() {
        sut.start()
        sut.switchMode(.longBreak)
        XCTAssertFalse(sut.isRunning)
    }

    func testWorkCompletionSwitchesToShortBreak() {
        sut.timeRemaining = 0
        sut.tick()

        XCTAssertEqual(sut.currentMode, .shortBreak)
        XCTAssertEqual(sut.completedPomodoros, 1)
    }

    func testWorkCompletionSwitchesToLongBreakAfterInterval() {
        sut.longBreakInterval = 2
        sut.completedPomodoros = 1

        sut.timeRemaining = 0
        sut.tick()

        XCTAssertEqual(sut.currentMode, .longBreak)
        XCTAssertEqual(sut.completedPomodoros, 2)
    }

    func testBreakCompletionSwitchesToWork() {
        sut.switchMode(.shortBreak)
        sut.timeRemaining = 0
        sut.tick()

        XCTAssertEqual(sut.currentMode, .work)
    }

    // MARK: - Duration Tests

    func testDurationForReturnsCorrectValues() {
        sut.workDuration = 30
        sut.shortBreakDuration = 10
        sut.longBreakDuration = 20

        XCTAssertEqual(sut.durationFor(.work), 30 * 60)
        XCTAssertEqual(sut.durationFor(.shortBreak), 10 * 60)
        XCTAssertEqual(sut.durationFor(.longBreak), 20 * 60)
    }

    func testChangingDurationUpdatesTimeRemainingWhenNotRunning() {
        sut.workDuration = 30
        XCTAssertEqual(sut.timeRemaining, 30 * 60)
    }

    func testChangingDurationDoesNotUpdateTimeRemainingWhenRunning() {
        sut.start()
        let initialTime = sut.timeRemaining
        sut.workDuration = 30
        XCTAssertEqual(sut.timeRemaining, initialTime)
        sut.pause()
    }

    // MARK: - Progress Tests

    func testProgressIsZeroAtStart() {
        sut.timeRemaining = sut.durationFor(.work)
        XCTAssertEqual(sut.progress, 0, accuracy: 0.001)
    }

    func testProgressIsOneAtEnd() {
        sut.timeRemaining = 0
        XCTAssertEqual(sut.progress, 1, accuracy: 0.001)
    }

    func testProgressIsHalfwayAtMiddle() {
        sut.timeRemaining = sut.durationFor(.work) / 2
        XCTAssertEqual(sut.progress, 0.5, accuracy: 0.001)
    }

    // MARK: - Time String Tests

    func testTimeStringFormatsCorrectly() {
        sut.timeRemaining = 5 * 60 + 30 // 5:30
        XCTAssertEqual(sut.timeString, "05:30")

        sut.timeRemaining = 25 * 60 // 25:00
        XCTAssertEqual(sut.timeString, "25:00")

        sut.timeRemaining = 59 // 0:59
        XCTAssertEqual(sut.timeString, "00:59")
    }

    // MARK: - Settings Persistence Tests

    func testSettingsArePersisted() {
        sut.workDuration = 45
        sut.shortBreakDuration = 15
        sut.longBreakDuration = 30
        sut.longBreakInterval = 6

        XCTAssertEqual(storage.integer(forKey: "workDuration"), 45)
        XCTAssertEqual(storage.integer(forKey: "shortBreakDuration"), 15)
        XCTAssertEqual(storage.integer(forKey: "longBreakDuration"), 30)
        XCTAssertEqual(storage.integer(forKey: "longBreakInterval"), 6)
    }

    func testResetToDefaults() {
        sut.workDuration = 45
        sut.shortBreakDuration = 15
        sut.longBreakDuration = 30
        sut.longBreakInterval = 6

        sut.resetToDefaults()

        XCTAssertEqual(sut.workDuration, 25)
        XCTAssertEqual(sut.shortBreakDuration, 5)
        XCTAssertEqual(sut.longBreakDuration, 15)
        XCTAssertEqual(sut.longBreakInterval, 4)
    }

    // MARK: - Session Recording Tests

    func testRecordSessionAddsToSessions() {
        sut.recordSession(mode: .work)
        XCTAssertEqual(sut.sessions.count, 1)
        XCTAssertEqual(sut.sessions.first?.mode, TimerMode.work.rawValue)
    }

    func testRecordSessionUsesDateProvider() {
        let fixedDate = Date(timeIntervalSince1970: 1000000)
        dateProvider.now = fixedDate

        sut.recordSession(mode: .work)

        XCTAssertEqual(sut.sessions.first?.date, fixedDate)
    }

    func testClearAllSessionsRemovesAllSessions() {
        sut.recordSession(mode: .work)
        sut.recordSession(mode: .shortBreak)
        sut.completedPomodoros = 5

        sut.clearAllSessions()

        XCTAssertTrue(sut.sessions.isEmpty)
        XCTAssertEqual(sut.completedPomodoros, 0)
    }

    // MARK: - Statistics Tests

    func testTodayCountCountsOnlyTodaySessions() {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        dateProvider.now = today

        sut.sessions = [
            PomodoroSession(mode: .work, date: today),
            PomodoroSession(mode: .work, date: today),
            PomodoroSession(mode: .work, date: yesterday),
            PomodoroSession(mode: .shortBreak, date: today) // Should not count
        ]

        XCTAssertEqual(sut.todayCount, 2)
    }

    func testWeekCountCountsLast7Days() {
        let calendar = Calendar.current
        let today = Date()
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!
        let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: today)!

        dateProvider.now = today

        sut.sessions = [
            PomodoroSession(mode: .work, date: today),
            PomodoroSession(mode: .work, date: threeDaysAgo),
            PomodoroSession(mode: .work, date: tenDaysAgo) // Should not count
        ]

        XCTAssertEqual(sut.weekCount, 2)
    }

    func testTotalCountCountsAllWorkSessions() {
        sut.sessions = [
            PomodoroSession(mode: .work, date: Date()),
            PomodoroSession(mode: .work, date: Date()),
            PomodoroSession(mode: .shortBreak, date: Date()),
            PomodoroSession(mode: .longBreak, date: Date())
        ]

        XCTAssertEqual(sut.totalCount, 2)
    }

    func testWeeklyStatsReturns7Days() {
        let stats = sut.weeklyStats
        XCTAssertEqual(stats.count, 7)
    }

    func testTotalFocusTimeStringFormatsCorrectly() {
        sut.workDuration = 25
        sut.sessions = [
            PomodoroSession(mode: .work, date: Date()),
            PomodoroSession(mode: .work, date: Date()),
            PomodoroSession(mode: .work, date: Date()) // 3 sessions * 25 min = 75 min = 1h 15m
        ]

        XCTAssertEqual(sut.totalFocusTimeString, "1h 15m")
    }

    func testTotalFocusTimeStringShowsMinutesOnly() {
        sut.workDuration = 25
        sut.sessions = [
            PomodoroSession(mode: .work, date: Date()) // 25 min
        ]

        XCTAssertEqual(sut.totalFocusTimeString, "25 min")
    }

    // MARK: - Notification Tests

    func testNotificationScheduledOnCompletion() {
        notificationService.authorizationGranted = true
        sut.notificationPermissionGranted = true

        sut.timeRemaining = 0
        sut.tick()

        XCTAssertEqual(notificationService.scheduledNotifications.count, 1)
        XCTAssertEqual(notificationService.scheduledNotifications.first?.title, "Focus Session Complete!")
    }

    func testNoNotificationWhenNotAuthorized() {
        notificationService.authorizationGranted = false
        sut.notificationPermissionGranted = false

        sut.timeRemaining = 0
        sut.tick()

        XCTAssertTrue(notificationService.scheduledNotifications.isEmpty)
    }

    // MARK: - Sound Tests

    func testSoundPlaysOnCompletion() {
        sut.timeRemaining = 0
        sut.tick()

        XCTAssertTrue(soundService.playCompletionSoundCalled)
    }
}
