import UIKit
import WebKit

class DetailViewController: UIViewController, ReceiverPresenter {
    weak var processor: (any Receiver<DetailAction>)?

    lazy var drawer = DrawerLabel().applying { drawer in
        drawer.translatesAutoresizingMaskIntoConstraints = false
        drawer.numberOfLines = 0
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
        Task {
            await processor?.receive(.initialData)
        }
    }

    func present(_ state: DetailState) async {
        drawer.attributedText = state.item.attributedTitle
        loadWebView(state)
    }

    func loadWebView(_ state: DetailState) {
        guard let templateURL = services.bundle.url(forResource: "htmltemplate", withExtension: "txt") else {
            return // shouldn't happen
        }
        guard var contentString = try? String(contentsOf: templateURL, encoding: .utf8) else {
            return // shouldn't happen
        }
        let pad = self.traitCollection.userInterfaceIdiom == .pad // TODO: check this for collapse on iPad
        contentString = contentString
            .replacingOccurrences(of:"<maximagewidth>", with:"80%")
            .replacingOccurrences(of:"<fontsize>", with: "18" /* String(self.fontsize) */)
            .replacingOccurrences(of:"<margin>", with: pad ? "20" : "5")
            .replacingOccurrences(of:"<guid>", with: state.item.guid)
            .replacingOccurrences(of:"<author>", with: state.item.author ?? "")
            .replacingOccurrences(of: "<content>", with: state.item.content)
            .replacingOccurrences(of: "http://", with: "https://")
            .replacingOccurrences(of:"<date>", with: { () -> String in
                let format = Date.VerbatimFormatStyle(
                    format: "\(day: .defaultDigits) \(month: .wide) \(year: .defaultDigits)",
                    locale: Locale(identifier: "en_US"),
                    timeZone: .autoupdatingCurrent,
                    calendar: .init(identifier:.gregorian)
                )
                return state.item.pubDate.formatted(format)
            }())
        self.webView.loadHTMLString(contentString, baseURL: templateURL)
    }
}
