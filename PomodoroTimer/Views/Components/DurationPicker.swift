import SwiftUI

struct DurationPicker: View {
    let title: String
    @Binding var minutes: Int
    let range: ClosedRange<Int>

    var body: some View {
        HStack {
            Text(title)

            Spacer()

            Picker("", selection: $minutes) {
                ForEach(Array(range), id: \.self) { value in
                    Text("\(value) min").tag(value)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

#Preview {
    Form {
        DurationPicker(title: "Focus", minutes: .constant(25), range: 1...60)
    }
}
