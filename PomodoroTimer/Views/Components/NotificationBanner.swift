import SwiftUI

struct NotificationBanner: View {
    let onEnable: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "bell.badge")
                .foregroundColor(.orange)

            Text("Enable notifications to know when timer ends")
                .font(.caption)
                .foregroundColor(.primary)

            Spacer()

            Button("Enable") {
                onEnable()
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.orange))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
        .padding()
    }
}

#Preview {
    NotificationBanner {}
}
