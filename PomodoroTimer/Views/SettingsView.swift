import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Timer Durations") {
                    DurationPicker(
                        title: "Focus",
                        minutes: $viewModel.workDuration,
                        range: 1...60
                    )

                    DurationPicker(
                        title: "Short Break",
                        minutes: $viewModel.shortBreakDuration,
                        range: 1...30
                    )

                    DurationPicker(
                        title: "Long Break",
                        minutes: $viewModel.longBreakDuration,
                        range: 1...60
                    )
                }

                Section("Long Break Interval") {
                    Stepper(
                        "\(viewModel.longBreakInterval) pomodoros",
                        value: $viewModel.longBreakInterval,
                        in: 2...8
                    )
                }

                Section("Notification Sound") {
                    SoundPicker(
                        selectedSound: Binding(
                            get: { viewModel.selectedSound },
                            set: { viewModel.selectedSound = $0 }
                        ),
                        onPreview: { sound in
                            viewModel.previewSound(sound)
                        }
                    )
                }

                Section {
                    Button("Reset to Defaults") {
                        viewModel.resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: TimerViewModel())
}
