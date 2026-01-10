import UIKit

protocol RootCoordinatorType: AnyObject {
    func createInterface(window: UIWindow)
    func showDetail(item: FeedItem)
    func showURL(_: URL)
    @discardableResult func showAlert(title: String?, message: String?, buttonTitles: [String]) async -> String?
}

final class RootCoordinator: RootCoordinatorType {
    weak var rootViewController: UIViewController?

    var splitViewController: UISplitViewController? {
        rootViewController as? UISplitViewController
    }

    var masterProcessor: (any Processor<MasterAction, MasterState, MasterEffect>)?
    var detailProcessor: (any Processor<DetailAction, DetailState, DetailEffect>)?

    func createInterface(window: UIWindow) {
        let splitViewController = UISplitViewController(style: .doubleColumn)
        self.rootViewController = splitViewController
        window.rootViewController = splitViewController
        splitViewController.preferredSplitBehavior = .tile
        splitViewController.preferredDisplayMode = .oneBesideSecondary
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

    /// Secondary reference to the continuation on `showAlert`, so we can resume it from tests.
    var alertContinuation: CheckedContinuation<String?, Never>?

    func showAlert(title: String?, message: String?, buttonTitles: [String]) async -> String? {
        guard !(title == nil && message == nil) else { return nil }
        return await withCheckedContinuation { continuation in
            self.alertContinuation = continuation
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            for title in buttonTitles {
                alert.addAction(UIAlertAction(title: title, style: .default, handler: { action in
                    continuation.resume(returning: action.title)
                    self.alertContinuation = nil
                }))
            }
            rootViewController?.present(alert, animated: unlessTesting(true))
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
