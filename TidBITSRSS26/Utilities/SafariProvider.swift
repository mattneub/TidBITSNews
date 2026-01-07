import SafariServices
import UIKit

protocol SafariProviderType {
    func provide(for url: URL) -> UIViewController
}

final class SafariProvider: SafariProviderType {
    func provide(for url: URL) -> UIViewController {
        return SFSafariViewController(url: url)
    }
}
