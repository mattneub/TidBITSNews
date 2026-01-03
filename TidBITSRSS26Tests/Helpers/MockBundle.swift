@testable import TidBITSRSS26
import Foundation

final class MockBundle: BundleType {
    var methodsCalled = [String]()
    var resource: String?
    var ext: String?
    var urlToReturn: URL?
    func url(forResource: String?, withExtension: String?) -> URL? {
        methodsCalled.append(#function)
        resource = forResource
        ext = withExtension
        return urlToReturn
    }

}
