import Foundation

protocol DateProviderProtocol {
    var now: Date { get }
    var calendar: Calendar { get }
}

struct SystemDateProvider: DateProviderProtocol {
    var now: Date { Date() }
    var calendar: Calendar { Calendar.current }
}
