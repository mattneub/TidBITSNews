import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    var coordinator: (any RootCoordinatorType) = RootCoordinator()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = scene as? UIWindowScene else {
            return
        }
        unlessTesting {
            bootstrap(scene: scene)
        }
    }

    func bootstrap(scene: UIWindowScene) {
        let window = UIWindow(windowScene: scene)
        window.backgroundColor = .systemBackground
        window.tintColor = .myPurple
        self.window = window
        coordinator.createInterface(window: window)
        window.makeKeyAndVisible()
    }
}

