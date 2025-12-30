@testable import TidBITSRSS26
import UIKit

final class MockRootCoordinator: RootCoordinatorType {
    var methodsCalled = [String]()
    var window: UIWindow?

    func createInterface(window: UIWindow) {
        methodsCalled.append(#function)
        self.window = window
    }
}

