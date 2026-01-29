import SwiftUI

struct TimerControls: View {
    let isRunning: Bool
    let color: Color
    let onReset: () -> Void
    let onStartPause: () -> Void
    let onSkip: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            // Reset Button
            Button(action: onReset) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color(.systemGray6))
                    )
            }

            // Play/Pause Button
            Button(action: onStartPause) {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(color)
                    )
            }

            // Skip Button
            Button(action: onSkip) {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color(.systemGray6))
                    )
            }
        }
    }
}

#Preview {
    TimerControls(
        isRunning: false,
        color: .red,
        onReset: {},
        onStartPause: {},
        onSkip: {}
    )
}
