import UIKit
import WebKit

class DetailViewController: UIViewController, ReceiverPresenter {
    weak var processor: (any Receiver<DetailAction>)?

    lazy var drawer = DrawerLabel().applying { drawer in
        drawer.translatesAutoresizingMaskIntoConstraints = false
        drawer.numberOfLines = 0
        drawer.isHidden = true
    }

    lazy var webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration().applying {
        $0.suppressesIncrementalRendering = true
    }).applying {
        $0.allowsLinkPreview = false
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(drawer)
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            drawer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            drawer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            drawer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: drawer.bottomAnchor),
        ])
    }

    func present(_ state: DetailState) async {
        drawer.attributedText = state.item.attributedTitle
        drawer.isHidden = false
        loadWebView(state)
    }

    func loadWebView(_ state: DetailState) {
        // we have to do this part of the substitution, because we know what a trait collection is
        // and the processor doesn't
        // TODO: look into that
        let pad = self.traitCollection.userInterfaceIdiom == .pad // TODO: check this for collapse on iPad
        let contentString = state.contentString .replacingOccurrences(of:"<margin>", with: pad ? "20" : "5")
        self.webView.loadHTMLString(contentString, baseURL: state.templateURL)
    }
}
