import UIKit
@testable import TidBITSRSS26

final class MockSafariProvider: SafariProviderType {
    var methodsCalled = [String]()
    var url: URL?

    func provide(for url: URL) -> UIViewController {
        methodsCalled.append(#function)
        self.url = url
        return MockSafariViewController()
    }
}

final class MockSafariViewController: UIViewController {}
