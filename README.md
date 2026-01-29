# Pomodoro Timer

A clean, minimal Pomodoro Timer app built with SwiftUI for iOS. This app helps you stay focused and productive using the Pomodoro Technique.

## Features

- **Focus Timer**: 25-minute work sessions with customizable duration
- **Break Timers**: Short (5 min) and long (15 min) breaks with automatic transitions
- **Visual Progress**: Animated circular progress ring with real-time countdown
- **Statistics**: Track completed sessions with daily, weekly, and total counts
- **Charts**: Visual weekly statistics using Swift Charts
- **Notifications**: Local notifications when timers complete
- **Sound Alerts**: Customizable completion sounds (6 options)
- **Persistence**: Settings and session history saved to UserDefaults
- **Dark Mode**: Full support for iOS dark mode

## Screenshots

The app features a clean, minimal design with:
- Large circular timer display
- Mode selector (Focus/Short Break/Long Break)
- Start/Pause and Reset controls
- Settings and Statistics accessible via toolbar

## Architecture

This project follows **MVVM (Model-View-ViewModel)** architecture with **Protocol-Oriented Programming** and **Dependency Injection** for testability.

### Project Structure

```
PomodoroTimer/
├── App/
│   └── PomodoroTimerApp.swift      # App entry point
├── Models/
│   ├── TimerMode.swift             # Timer mode enum (work/shortBreak/longBreak)
│   ├── PomodoroSession.swift       # Session data model
│   ├── DailyStat.swift             # Daily statistics model
│   └── SoundOption.swift           # Sound selection enum
├── ViewModels/
│   └── TimerViewModel.swift        # Main business logic
├── Views/
│   ├── ContentView.swift           # Main timer screen
│   ├── SettingsView.swift          # Settings screen
│   ├── StatisticsView.swift        # Statistics screen
│   └── Components/
│       ├── TimerRing.swift         # Circular progress indicator
│       ├── TimerControls.swift     # Start/Pause/Reset buttons
│       ├── ModeButton.swift        # Timer mode selector
│       ├── PomodoroCounter.swift   # Completed sessions display
│       ├── DurationPicker.swift    # Duration stepper
│       ├── SoundPicker.swift       # Sound selection list
│       ├── StatCard.swift          # Statistics card
│       └── NotificationBanner.swift # Permission banner
├── Services/
│   ├── SoundManager.swift          # Audio playback implementation
│   └── Protocols/
│       ├── StorageProtocol.swift           # Persistence abstraction
│       ├── DateProviderProtocol.swift      # Date/time abstraction
│       ├── NotificationServiceProtocol.swift # Notifications abstraction
│       └── SoundServiceProtocol.swift      # Sound playback abstraction
└── Resources/
    └── Assets.xcassets             # App icons and colors
```

### Design Principles

#### 1. Dependency Injection

All external dependencies are injected through protocols, making the code testable and flexible:

```swift
class TimerViewModel: ObservableObject {
    init(
        storage: StorageProtocol = UserDefaults.standard,
        dateProvider: DateProviderProtocol = SystemDateProvider(),
        notificationService: NotificationServiceProtocol = SystemNotificationService(),
        soundService: SoundServiceProtocol = SoundManager.shared
    ) { ... }
}
```

#### 2. Protocol-Oriented Design

Each external dependency has a protocol abstraction:

- **StorageProtocol**: Abstracts UserDefaults for data persistence
- **DateProviderProtocol**: Abstracts Date() and Calendar for time operations
- **NotificationServiceProtocol**: Abstracts UNUserNotificationCenter
- **SoundServiceProtocol**: Abstracts audio playback

#### 3. Single Source of Truth

`TimerViewModel` is the single source of truth for all timer state:
- Uses `@Published` properties for reactive UI updates
- All state mutations go through the ViewModel
- Views are purely declarative

#### 4. Immutable Models

Models are simple value types:

```swift
struct PomodoroSession: Codable, Identifiable {
    var id: Date { date }  // Stable identity
    let mode: String
    let date: Date
}
```

### Key Components

#### TimerViewModel

The central ViewModel managing:
- Timer state (running, paused, time remaining)
- Mode transitions (work → break → work)
- Session recording and statistics
- Settings persistence
- Notification scheduling

#### Service Layer

- **SoundManager**: Singleton for audio playback using AVFoundation and AudioToolbox
- **SystemNotificationService**: Wrapper around UNUserNotificationCenter
- **SystemDateProvider**: Provides current date and calendar

### Testing

The architecture supports comprehensive unit testing through mock implementations:

```
PomodoroTimerTests/
├── TimerViewModelTests.swift    # 30+ test cases
└── Mocks/
    ├── MockStorage.swift
    ├── MockDateProvider.swift
    ├── MockNotificationService.swift
    └── MockSoundService.swift
```

Example test:

```swift
func testTimerCompletion() async {
    let viewModel = TimerViewModel(
        storage: MockStorage(),
        dateProvider: MockDateProvider(),
        notificationService: MockNotificationService(),
        soundService: mockSoundService
    )

    viewModel.timeRemaining = 1
    viewModel.start()
    viewModel.tick()

    XCTAssertTrue(mockSoundService.playCompletionSoundCalled)
    XCTAssertEqual(viewModel.currentMode, .shortBreak)
}
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/PomodoroTimer.git
   ```

2. Open `PomodoroTimer.xcodeproj` in Xcode

3. Build and run on simulator or device

## Usage

1. **Start a Focus Session**: Tap the play button to start a 25-minute focus session
2. **Take Breaks**: After completing a focus session, the app automatically switches to break mode
3. **Long Breaks**: Every 4 pomodoros, you get a longer 15-minute break
4. **Customize**: Open Settings to adjust durations and notification sounds
5. **Track Progress**: View your statistics to see completed sessions

## Technologies Used

- **SwiftUI**: Declarative UI framework
- **Swift Charts**: Native charting for statistics
- **UserNotifications**: Local notification scheduling
- **AVFoundation & AudioToolbox**: Audio playback
- **Combine**: Reactive programming with @Published

## License

MIT License - feel free to use this project for learning or as a starting point for your own apps.
