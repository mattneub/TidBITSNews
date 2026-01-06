import UIKit

/// The single global Services instance is rooted here.
@MainActor
let services = Services()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
}

// TODO: Accessibility

// TODO: What happens when you tap a link or the header or title or whatever
