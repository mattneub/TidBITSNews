import UIKit
@testable import TidBITSRSS26

@discardableResult
func makeWindow(viewController: UIViewController? = nil) -> UIWindow {
    // construct interface artificially
    let scene = UIApplication.shared.connectedScenes.first! as! UIWindowScene
    let delegate = scene.delegate as! SceneDelegate
    let window = UIWindow(windowScene: scene)
    delegate.window = window
    let viewController = viewController ?? UIViewController()
    window.rootViewController = viewController
    window.makeKeyAndVisible()
    window.backgroundColor = .yellow
    return window
}

@discardableResult
func makeWindow(view: UIView) -> UIWindow {
    let viewController = UIViewController()
    let window = makeWindow(viewController: viewController)
    viewController.view.addSubview(view)
    view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
        viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
    window.layoutIfNeeded()
    return window
}

