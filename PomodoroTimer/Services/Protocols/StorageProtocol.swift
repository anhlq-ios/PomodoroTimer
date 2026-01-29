import Foundation

protocol StorageProtocol {
    func integer(forKey key: String) -> Int?
    func set(_ value: Int, forKey key: String)
    func data(forKey key: String) -> Data?
    func set(_ data: Data, forKey key: String)
    func removeObject(forKey key: String)
}

extension UserDefaults: StorageProtocol {
    func integer(forKey key: String) -> Int? {
        object(forKey: key) as? Int
    }

    func set(_ value: Int, forKey key: String) {
        set(value as Any, forKey: key)
    }

    func set(_ data: Data, forKey key: String) {
        set(data as Any, forKey: key)
    }
}
