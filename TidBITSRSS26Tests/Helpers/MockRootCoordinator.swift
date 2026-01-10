@testable import TidBITSRSS26
import UIKit

final class MockRootCoordinator: RootCoordinatorType {
    var methodsCalled = [String]()
    var window: UIWindow?
    var feedItem: FeedItem?
    var url: URL?
    var title: String?
    var message: String?
    var buttonTitles = [String]()
    var titleToReturn: String? = nil

    func createInterface(window: UIWindow) {
        methodsCalled.append(#function)
        self.window = window
    }

    func showDetail(item: FeedItem) {
        methodsCalled.append(#function)
        self.feedItem = item
    }

    func showURL(_ url: URL) {
        methodsCalled.append(#function)
        self.url = url
    }

    func showAlert(title: String?, message: String?, buttonTitles: [String]) async -> String? {
        methodsCalled.append(#function)
        self.title = title
        self.message = message
        self.buttonTitles = buttonTitles
        return titleToReturn
    }

}

