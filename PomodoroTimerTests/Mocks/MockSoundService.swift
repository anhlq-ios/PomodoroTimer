import Foundation
@testable import PomodoroTimer

class MockSoundService: SoundServiceProtocol {
    var selectedSound: SoundOption = .triTone
    var playCompletionSoundCalled = false
    var previewedSound: SoundOption?

    func playCompletionSound() {
        playCompletionSoundCalled = true
    }

    func playPreview(sound: SoundOption) {
        previewedSound = sound
    }
}
