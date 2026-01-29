import SwiftUI

struct PomodoroCounter: View {
    let completedPomodoros: Int
    let interval: Int
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(0..<interval, id: \.self) { index in
                    Circle()
                        .fill(index < completedPomodoros % interval ? color : Color(.systemGray4))
                        .frame(width: 12, height: 12)
                }
            }

            Text("\(completedPomodoros) pomodoros completed")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    PomodoroCounter(completedPomodoros: 2, interval: 4, color: .red)
}
