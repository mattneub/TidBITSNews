@testable import TidBITSRSS26
import Testing
import UIKit
import WaitWhile

private struct RootCoordinatorTests {
    let subject = RootCoordinator()

    @Test("createInterface: sets up root module, split view controller, and master module")
    func createInterface() throws {
        let window = UIWindow()
        subject.createInterface(window: window)
        let processor = try #require(subject.rootProcessor as? RootProcessor)
        #expect(processor.coordinator === subject)
        let viewController = try #require(processor.presenter as? RootViewController)
        #expect(viewController.processor === processor)
        #expect(window.rootViewController === viewController)
        #expect(viewController.children.count == 1)
        #expect(viewController.children.first is UISplitViewController)
        #expect(subject.splitViewController === viewController.children.first)
        #expect(subject.splitViewController!.view.isDescendant(of: viewController.view))
        #expect(subject.splitViewController!.style == .doubleColumn)
        #expect(subject.splitViewController!.splitBehavior == .tile)
        #expect(subject.splitViewController!.delegate === subject)
        do {
            let viewController = try #require(subject.splitViewController?.viewControllers[0] as? MasterViewController)
            #expect(subject.splitViewController?.viewController(for: .primary) === viewController)
            let processor = try #require(subject.masterProcessor as? MasterProcessor)
            #expect(processor.coordinator === subject)
            #expect(processor.presenter === viewController)
            #expect(viewController.processor === processor)
        }
        do {
            let viewController = try #require(subject.splitViewController?.viewControllers[1] as? DetailViewController)
            #expect(subject.splitViewController?.viewController(for: .secondary) === viewController)
            let processor = try #require(subject.detailProcessor as? DetailProcessor)
            #expect(processor.coordinator === subject)
            #expect(processor.delegate === subject.masterProcessor)
            #expect(processor.presenter === viewController)
            #expect(viewController.processor === processor)
        }
    }

    @Test("showDetail: sends state to detail processor and shows svc secondary")
    func showDetail() async throws {
        let processor = MockProcessor<DetailAction, DetailState, DetailEffect>()
        subject.detailProcessor = processor
        let splitViewController = MockSplitViewController()
        let viewController = UIViewController()
        subject.rootViewController = viewController
        viewController.addChild(splitViewController)
        let item = FeedItem(guid: "newguid")
        subject.showDetail(item: item)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.newItem(item)])
        #expect(splitViewController.methodsCalled == ["show(_:)"])
        #expect(splitViewController.column == .secondary)
    }

    @Test("showURL: calls safari provider for view controller, presents it on root view controller")
    func showURL() async {
        let safariProvider = MockSafariProvider()
        services.safariProvider = safariProvider
        let url = URL(string: "https://www.example.com")!
        let rootViewController = UIViewController()
        subject.rootViewController = rootViewController
        makeWindow(viewController: rootViewController)
        subject.showURL(url)
        #expect(safariProvider.methodsCalled == ["provide(for:)"])
        #expect(safariProvider.url == url)
        await #while(rootViewController.presentedViewController == nil)
        #expect(rootViewController.presentedViewController is MockSafariViewController)
    }

    @Test("top column for collapse is primary")
    func topColumn() {
        let result = subject.splitViewController(
            UISplitViewController(),
            topColumnForCollapsingToProposedTopColumn: .secondary
        )
        #expect(result == .primary)
    }
}
