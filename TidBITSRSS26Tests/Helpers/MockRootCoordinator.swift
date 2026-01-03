@testable import TidBITSRSS26
import UIKit

final class MockRootCoordinator: RootCoordinatorType {
    var methodsCalled = [String]()
    var window: UIWindow?
    var detailState: DetailState?

    func createInterface(window: UIWindow) {
        methodsCalled.append(#function)
        self.window = window
    }

    func showDetail(state: DetailState) {
        methodsCalled.append(#function)
        self.detailState = state
    }
}

