import Foundation
@testable import PomodoroTimer

class MockDateProvider: DateProviderProtocol {
    var now: Date
    var calendar: Calendar

    init(now: Date = Date(), calendar: Calendar = .current) {
        self.now = now
        self.calendar = calendar
    }
}
