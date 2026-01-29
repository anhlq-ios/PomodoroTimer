import Foundation

protocol SoundServiceProtocol {
    var selectedSound: SoundOption { get set }
    func playCompletionSound()
    func playPreview(sound: SoundOption)
}
