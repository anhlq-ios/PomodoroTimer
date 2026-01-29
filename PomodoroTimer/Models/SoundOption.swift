import Foundation

enum SoundOption: String, CaseIterable, Codable, Identifiable {
    case triTone = "Tri-tone"
    case chime = "Chime"
    case bell = "Bell"
    case digital = "Digital"
    case gentle = "Gentle"
    case none = "None"

    var id: String { rawValue }

    var systemSoundID: UInt32? {
        switch self {
        case .triTone: return 1013
        case .chime: return 1025
        case .bell: return 1016
        case .digital: return 1007
        case .gentle: return 1001
        case .none: return nil
        }
    }

    var iconName: String {
        switch self {
        case .triTone: return "waveform.path"
        case .chime: return "bell.fill"
        case .bell: return "bell.badge.fill"
        case .digital: return "desktopcomputer"
        case .gentle: return "leaf.fill"
        case .none: return "speaker.slash.fill"
        }
    }
}
