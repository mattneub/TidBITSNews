import UIKit

protocol RootCoordinatorType: AnyObject {
    func createInterface(window: UIWindow)
    func showDetail(state: DetailState)
}

final class RootCoordinator: RootCoordinatorType {
    weak var rootViewController: UIViewController?

    var splitViewController: UISplitViewController? {
        rootViewController?.children.first as? UISplitViewController
    }

    var rootProcessor: (any Processor<RootAction, RootState, Void>)?
    var masterProcessor: (any Processor<MasterAction, MasterState, Void>)?
    var detailProcessor: (any Processor<DetailAction, DetailState, Void>)?

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
            let viewController = DetailViewController()
            processor.presenter = viewController
            viewController.processor = processor
            splitViewController.setViewController(viewController, for: .secondary)
        }
    }

    func showDetail(state: DetailState) {
        Task {
            await detailProcessor?.receive(.newState(state))
            splitViewController?.show(.secondary)
        }
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
