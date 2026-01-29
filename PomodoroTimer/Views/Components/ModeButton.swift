import SwiftUI

struct ModeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .primary : .secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(.systemGray5) : Color.clear)
                )
        }
    }
}

#Preview {
    HStack {
        ModeButton(title: "Focus", isSelected: true) {}
        ModeButton(title: "Break", isSelected: false) {}
    }
}
