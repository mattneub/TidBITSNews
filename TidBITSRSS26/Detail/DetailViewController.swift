import UIKit
import WebKit

class DetailViewController: UIViewController, ReceiverPresenter {
    weak var processor: (any Receiver<DetailAction>)?

    lazy var drawer = DrawerLabel().applying { drawer in
        drawer.translatesAutoresizingMaskIntoConstraints = false
        drawer.numberOfLines = 0
        drawer.isHidden = true
        drawer.adjustsFontForContentSizeCategory = true
        drawer.backgroundColor = .systemBackground
        drawer.isUserInteractionEnabled = true
        let tapper = MyTapGestureRecognizer(target: self, action: #selector(doTapTitle))
        drawer.addGestureRecognizer(tapper)
        drawer.accessibilityTraits = .header
    }

    lazy var fontSizeButton = UIBarButtonItem(
        image: UIImage(named: "fontsize"),
        style: .plain,
        target: self,
        action: #selector(doFontSize)
    ).applying {
        $0.tintColor = .myPurple
        $0.accessibilityLabel = "Font size"
        $0.accessibilityHint = "Tap to change article font size."
    }

    lazy var webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration().applying {
        $0.suppressesIncrementalRendering = true
    }).applying {
        $0.allowsLinkPreview = false
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.navigationDelegate = self
    }

    lazy var nextPrev = UISegmentedControl(
        items: [
            UIImage(named: "prev") as Any,
            UIImage(named: "next") as Any
        ]
    ).applying {
        $0.isMomentary = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        // needed because `tintColor` no longer has any effect on segmented control, whether set or inherited!
        $0.setTitleTextAttributes([
            .foregroundColor: UIColor.myPurple
        ], for: .normal)
        $0.setTitleTextAttributes([
            .foregroundColor: UIColor.white
        ], for: .selected)
        $0.setTitleTextAttributes([
            .foregroundColor: UIColor.clear
        ], for: .disabled)
        $0.heightAnchor.constraint(equalToConstant: 34).activate()
        $0.widthAnchor.constraint(equalToConstant: 126).activate()
        $0.addTarget(self, action: #selector(doNextPrev), for: .valueChanged)
        $0.backgroundColor = UIColor { traits in
            switch traits.userInterfaceStyle {
            case .dark: .myPurple * 0.8 + .black * 0.2
            default: .myPurple * 0.2 + .white * 0.8
            }
        }
        if let image = $0.imageForSegment(at: 0) {
            image.accessibilityLabel = "Previous article"
        }
        if let image = $0.imageForSegment(at: 1) {
            image.accessibilityLabel = "Next article"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor { traits in
            switch traits.userInterfaceStyle {
            case .dark: .myPurple * 0.8 + .black * 0.2
            default: .myPurple * 0.4 + .white * 0.6
            }
        }
        view.addSubview(drawer)
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            drawer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            drawer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            drawer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: drawer.bottomAnchor),
        ])
        navigationItem.titleView = nextPrev
        navigationItem.rightBarButtonItem = fontSizeButton
    }

    func present(_ state: DetailState) async {
        drawer.attributedText = state.item.attributedTitle
        drawer.isHidden = false
        loadWebView(state)
        nextPrev.setEnabled(!state.item.isFirst, forSegmentAt: 0)
        nextPrev.setEnabled(!state.item.isLast, forSegmentAt: 1)
        fontSizeButton.accessibilityValue = String(state.fontSize)
    }

    func receive(_ effect: DetailEffect) async {
        switch effect {
        case .newFontSize(let cssToInject, let newSize):
            _ = try? await webView.evaluateJavaScript(cssToInject)
            fontSizeButton.accessibilityValue = String(newSize)
        }
    }

    func loadWebView(_ state: DetailState) {
        // we have to do this part of the substitution, because we know what a trait collection is
        // and the processor / state doesn't
        // TODO: look into that
        let pad = self.traitCollection.userInterfaceIdiom == .pad // TODO: check this for collapse on iPad
        let contentString = state.contentString
            .replacingOccurrences(of:"<margin>", with: pad ? "20" : "5")
        self.webView.loadHTMLString(contentString, baseURL: state.templateURL)
    }

    @objc func doNextPrev(_ sender: UISegmentedControl) {
        Task {
            switch sender.selectedSegmentIndex {
            case 0: await processor?.receive(.goPrev)
            default: await processor?.receive(.goNext)
            }
        }
    }

    @objc func doFontSize(_ sender: Any) {
        Task {
            await processor?.receive(.changeFontSize)
        }
    }

    func doURL(_ url: URL) {
        Task {
            await processor?.receive(.doURL(url))
        }
    }

    @objc func doTapTitle() {
        let oldColor = drawer.backgroundColor
        self.drawer.backgroundColor = .systemYellow
        Task {
            try? await Task.sleep(for: .seconds(0.1))
            self.drawer.backgroundColor = oldColor
            await processor?.receive(.tapTitle)
        }
    }
}

extension DetailViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                doURL(url)
                return .cancel
            }
        }
        // must always return _something_
        return .allow
    }
}
