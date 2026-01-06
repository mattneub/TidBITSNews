import Foundation
@testable import TidBITSRSS26

final class MockUserDefaults: UserDefaultsType {
    var methodsCalled = [String]()
    var sets = [String: Any?]()
    var gets = [String: Any?]()

    func set(_ what: Any?, forKey key: String) {
        methodsCalled.append(#function)
        sets[key] = what
    }

    func data(forKey key: String) -> Data? {
        methodsCalled.append(#function)
        return gets[key] as? Data
    }
}
