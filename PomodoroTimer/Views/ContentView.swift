import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()
    @State private var showSettings = false
    @State private var showStatistics = false

    var body: some View {
        ZStack {
            viewModel.currentMode.color
                .opacity(0.1)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                headerView
                modeSelector
                Spacer()
                timerRing
                Spacer()
                timerControls
                pomodoroCounter
            }

            notificationBanner
        }
        .onAppear {
            viewModel.requestNotificationPermission()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showStatistics) {
            StatisticsView(viewModel: viewModel)
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack {
            Button(action: { showStatistics = true }) {
                Image(systemName: "chart.bar.fill")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(width: 44, height: 44)
            }
            Spacer()
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var modeSelector: some View {
        HStack(spacing: 20) {
            ForEach(TimerMode.allCases, id: \.self) { mode in
                ModeButton(
                    title: mode.rawValue,
                    isSelected: viewModel.currentMode == mode
                ) {
                    viewModel.switchMode(mode)
                }
            }
        }
    }

    private var timerRing: some View {
        TimerRing(
            progress: viewModel.progress,
            timeString: viewModel.timeString,
            modeTitle: viewModel.currentMode.rawValue,
            color: viewModel.currentMode.color
        )
    }

    private var timerControls: some View {
        TimerControls(
            isRunning: viewModel.isRunning,
            color: viewModel.currentMode.color,
            onReset: viewModel.reset,
            onStartPause: viewModel.startPause,
            onSkip: skipToNextMode
        )
    }

    private var pomodoroCounter: some View {
        PomodoroCounter(
            completedPomodoros: viewModel.completedPomodoros,
            interval: viewModel.longBreakInterval,
            color: viewModel.currentMode.color
        )
        .padding(.top, 20)
        .padding(.bottom, 40)
    }

    @ViewBuilder
    private var notificationBanner: some View {
        if !viewModel.notificationPermissionGranted {
            VStack {
                Spacer()
                NotificationBanner {
                    viewModel.requestNotificationPermission()
                }
            }
            .transition(.move(edge: .bottom))
        }
    }

    // MARK: - Actions

    private func skipToNextMode() {
        if viewModel.currentMode == .work {
            if viewModel.completedPomodoros % viewModel.longBreakInterval == viewModel.longBreakInterval - 1 {
                viewModel.switchMode(.longBreak)
            } else {
                viewModel.switchMode(.shortBreak)
            }
        } else {
            viewModel.switchMode(.work)
        }
    }
}

#Preview {
    ContentView()
}
