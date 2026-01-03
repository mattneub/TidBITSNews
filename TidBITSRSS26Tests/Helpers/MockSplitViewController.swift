@testable import TidBITSRSS26
import UIKit

final class MockSplitViewController: UISplitViewController {
    var methodsCalled = [String]()
    var column: UISplitViewController.Column?

    override func show(_ column: UISplitViewController.Column) {
        methodsCalled.append(#function)
        self.column = column
    }
}
