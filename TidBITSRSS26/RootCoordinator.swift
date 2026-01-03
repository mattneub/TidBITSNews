import UIKit

protocol RootCoordinatorType: AnyObject {
    func createInterface(window: UIWindow)
    func showDetail(state: DetailState)
}

final class RootCoordinator: RootCoordinatorType {
    weak var rootViewController: UIViewController?

    var navigationController: UINavigationController? {
        rootViewController?.children.first as? UINavigationController
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
        do {
            let processor = MasterProcessor()
            self.masterProcessor = processor
            processor.coordinator = self
            let viewController = MasterViewController()
            processor.presenter = viewController
            viewController.processor = processor
            let navigationController = UINavigationController(rootViewController: viewController)
            rootViewController?.addChild(navigationController)
            rootViewController?.view.addSubview(navigationController.view)
            navigationController.view.frame = rootViewController?.view.bounds ?? .zero
            navigationController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }

    func showDetail(state: DetailState) {
        let processor = DetailProcessor()
        self.detailProcessor = processor
        processor.coordinator = self
        processor.state = state
        let viewController = DetailViewController()
        processor.presenter = viewController
        viewController.processor = processor
        navigationController?.pushViewController(viewController, animated: unlessTesting(true))
    }

}
