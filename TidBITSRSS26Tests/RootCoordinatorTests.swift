@testable import TidBITSRSS26
import Testing
import UIKit

private struct RootCoordinatorTests {
    let subject = RootCoordinator()

    @Test("createInterface: sets up root module and dependent modules")
    func createInterface() throws {
        let window = UIWindow()
        subject.createInterface(window: window)
        let processor = try #require(subject.rootProcessor as? RootProcessor)
        #expect(processor.coordinator === subject)
        let viewController = try #require(processor.presenter as? RootViewController)
        #expect(viewController.processor === processor)
        #expect(window.rootViewController === viewController)
        do {
            #expect(viewController.children.count == 1)
            let navigationController = try #require(viewController.children[0] as? UINavigationController)
            let viewController = try #require(navigationController.children[0] as? MasterViewController)
            let processor = try #require(subject.masterProcessor as? MasterProcessor)
            #expect(processor.coordinator === subject)
            #expect(processor.presenter === viewController)
            #expect(viewController.processor === processor)
            #expect(navigationController.view.isDescendant(of: subject.rootViewController!.view))
        }
    }
}
