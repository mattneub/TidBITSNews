import UIKit

protocol RootCoordinatorType: AnyObject {
    func createInterface(window: UIWindow)
    func showDetail(item: FeedItem)
    func showURL(_: URL)
}

final class RootCoordinator: RootCoordinatorType {
    weak var rootViewController: UIViewController?

    var splitViewController: UISplitViewController? {
        rootViewController?.children.first as? UISplitViewController
    }

    var rootProcessor: (any Processor<RootAction, RootState, Void>)?
    var masterProcessor: (any Processor<MasterAction, MasterState, MasterEffect>)?
    var detailProcessor: (any Processor<DetailAction, DetailState, DetailEffect>)?

    func createInterface(window: UIWindow) {
        do {
            let processor = RootProcessor()
            self.rootProcessor = processor
            processor.coordinator = self
            let viewController = RootViewController()
            processor.presenter = viewController
            viewController.processor = processor
            window.rootViewController = viewController
            self.rootViewController = viewController
        }
        let splitViewController = UISplitViewController(style: .doubleColumn)
        rootViewController?.addChild(splitViewController)
        rootViewController?.view.addSubview(splitViewController.view)
        splitViewController.view.frame = rootViewController?.view.bounds ?? .zero
        splitViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        splitViewController.preferredSplitBehavior = .tile
        splitViewController.delegate = self
        do {
            let processor = MasterProcessor()
            self.masterProcessor = processor
            processor.coordinator = self
            let viewController = MasterViewController()
            processor.presenter = viewController
            viewController.processor = processor
            splitViewController.setViewController(viewController, for: .primary)
        }
        do {
            let processor = DetailProcessor()
            self.detailProcessor = processor
            processor.coordinator = self
            processor.delegate = masterProcessor as? DetailProcessorDelegate
            let viewController = DetailViewController()
            processor.presenter = viewController
            viewController.processor = processor
            splitViewController.setViewController(viewController, for: .secondary)
        }
    }

    func showDetail(item: FeedItem) {
        Task {
            await detailProcessor?.receive(.newItem(item))
            splitViewController?.show(.secondary)
        }
    }

    func showURL(_ url: URL) {
        let viewController = services.safariProvider.provide(for: url)
        viewController.modalPresentationStyle = .overCurrentContext
        rootViewController?.present(viewController, animated: unlessTesting(true))
    }
}

extension RootCoordinator: UISplitViewControllerDelegate {
    func splitViewController(
        _ svc: UISplitViewController,
        topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column
    ) -> UISplitViewController.Column {
        print("collapse!")
        return .primary
    }
}
