import Foundation

protocol UserDefaultsType {
    func set(_: Any?, forKey: String)
    func data(forKey: String) -> Data?
}

extension UserDefaults: UserDefaultsType {}
