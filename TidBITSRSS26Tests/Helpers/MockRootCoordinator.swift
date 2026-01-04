@testable import TidBITSRSS26
import UIKit

final class MockRootCoordinator: RootCoordinatorType {
    var methodsCalled = [String]()
    var window: UIWindow?
    var feedItem: FeedItem?

    func createInterface(window: UIWindow) {
        methodsCalled.append(#function)
        self.window = window
    }

    func showDetail(item: FeedItem) {
        methodsCalled.append(#function)
        self.feedItem = item
    }
}

