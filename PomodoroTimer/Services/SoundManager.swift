import AVFoundation
import AudioToolbox

final class SoundManager: SoundServiceProtocol {
    static let shared = SoundManager()

    private var audioPlayer: AVAudioPlayer?
    private let storageKey = "selectedSound"

    var selectedSound: SoundOption {
        didSet {
            saveSelectedSound()
        }
    }

    private init() {
        // Load saved sound preference
        if let savedValue = UserDefaults.standard.string(forKey: storageKey),
           let sound = SoundOption(rawValue: savedValue) {
            self.selectedSound = sound
        } else {
            self.selectedSound = .triTone
        }
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    func playCompletionSound() {
        playSound(selectedSound)
    }

    func playPreview(sound: SoundOption) {
        playSound(sound)
    }

    private func playSound(_ sound: SoundOption) {
        guard let soundID = sound.systemSoundID else { return }

        // Try bundled custom sound first
        if let customURL = Bundle.main.url(forResource: sound.rawValue.lowercased(), withExtension: "mp3") ??
                           Bundle.main.url(forResource: sound.rawValue.lowercased(), withExtension: "wav") {
            playCustomSound(from: customURL)
        } else {
            // Fall back to system sound
            AudioServicesPlaySystemSound(soundID)
        }
    }

    private func playCustomSound(from url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play custom sound: \(error)")
        }
    }

    private func saveSelectedSound() {
        UserDefaults.standard.set(selectedSound.rawValue, forKey: storageKey)
    }
}
