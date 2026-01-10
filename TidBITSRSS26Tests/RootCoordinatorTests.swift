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
        #expect(subject.rootViewController is UISplitViewController)
        #expect(window.rootViewController === subject.rootViewController)
        #expect(subject.splitViewController === subject.rootViewController)
        #expect(subject.splitViewController!.style == .doubleColumn)
        #expect(subject.splitViewController!.preferredSplitBehavior == .tile)
        #expect(subject.splitViewController!.preferredDisplayMode == .oneBesideSecondary)
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
        subject.rootViewController = splitViewController
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

    @Test("showAlert puts up the specified alert, returns tapped button title")
    func showAlert() async throws {
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        subject.rootViewController = viewController
        var result: String?
        Task {
            result = await subject.showAlert(title: "title", message: "message", buttonTitles: ["button1", "button2"])
        }
        await #while(viewController.presentedViewController == nil)
        let alert = try #require(viewController.presentedViewController as? UIAlertController)
        #expect(alert.title == "title")
        #expect(alert.message == "message")
        #expect(alert.actions[0].title == "button1")
        #expect(alert.actions[1].title == "button2")
        alert.tapButton(atIndex: 0)
        await #while(result == nil)
        #expect(result == "button1")
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
