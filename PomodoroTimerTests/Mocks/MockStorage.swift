import Foundation
@testable import PomodoroTimer

class MockStorage: StorageProtocol {
    var store: [String: Any] = [:]

    func integer(forKey key: String) -> Int? {
        store[key] as? Int
    }

    func set(_ value: Int, forKey key: String) {
        store[key] = value
    }

    func data(forKey key: String) -> Data? {
        store[key] as? Data
    }

    func set(_ data: Data, forKey key: String) {
        store[key] = data
    }

    func removeObject(forKey key: String) {
        store.removeValue(forKey: key)
    }
}
