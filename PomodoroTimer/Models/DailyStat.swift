import Foundation

struct DailyStat: Identifiable {
    let date: Date
    let count: Int

    var id: Date { date }

    var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}
