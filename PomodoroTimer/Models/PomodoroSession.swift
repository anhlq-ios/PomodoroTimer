import Foundation

struct PomodoroSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let mode: String

    init(mode: TimerMode, date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.mode = mode.rawValue
    }
}
