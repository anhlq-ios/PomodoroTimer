import SwiftUI

struct TimerRing: View {
    let progress: Double
    let timeString: String
    let modeTitle: String
    let color: Color

    var body: some View {
        ZStack {
            // Background Ring
            Circle()
                .stroke(lineWidth: 12)
                .opacity(0.1)
                .foregroundColor(color)

            // Progress Ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: 12,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

            // Time Text
            VStack(spacing: 8) {
                Text(timeString)
                    .font(.system(size: 64, weight: .light, design: .monospaced))
                    .foregroundColor(.primary)

                Text(modeTitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(2)
            }
        }
        .frame(width: 280, height: 280)
    }
}

#Preview {
    TimerRing(
        progress: 0.3,
        timeString: "17:30",
        modeTitle: "Focus",
        color: .red
    )
}
