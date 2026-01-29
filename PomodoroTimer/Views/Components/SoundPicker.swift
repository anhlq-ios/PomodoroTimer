import SwiftUI

struct SoundPicker: View {
    @Binding var selectedSound: SoundOption
    let onPreview: (SoundOption) -> Void

    var body: some View {
        ForEach(SoundOption.allCases) { sound in
            Button(action: {
                selectedSound = sound
                if sound != .none {
                    onPreview(sound)
                }
            }) {
                HStack {
                    Image(systemName: sound.iconName)
                        .foregroundColor(sound == .none ? .secondary : .accentColor)
                        .frame(width: 24)

                    Text(sound.rawValue)
                        .foregroundColor(.primary)

                    Spacer()

                    if selectedSound == sound {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

#Preview {
    Form {
        Section("Notification Sound") {
            SoundPicker(selectedSound: .constant(.triTone)) { _ in }
        }
    }
}
