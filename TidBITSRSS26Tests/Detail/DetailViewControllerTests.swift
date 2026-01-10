@testable import TidBITSRSS26
import Testing
import UIKit
import WebKit
import WaitWhile

private struct DetailViewControllerTests {
    let subject = DetailViewController()
    let processor = MockProcessor<DetailAction, DetailState, Void>()

    init() {
        subject.processor = processor
    }

    @Test("drawer label is correctly constructed")
    func drawer() throws {
        let drawer = subject.drawer
        #expect(drawer.translatesAutoresizingMaskIntoConstraints == false)
        #expect(drawer.numberOfLines == 0)
        #expect(drawer.adjustsFontForContentSizeCategory == true)
        #expect(drawer.backgroundColor == .systemBackground)
        #expect(drawer.isUserInteractionEnabled == true)
        #expect(drawer.accessibilityTraits == .header)
        let tapper = try #require(drawer.gestureRecognizers?[0] as? MyTapGestureRecognizer)
        #expect(tapper.target === subject)
        #expect(tapper.action == #selector(subject.doTapTitle))
    }

    @Test("fontSizeButton is correctly constructed")
    func fontSizeButton() {
        let button = subject.fontSizeButton
        #expect(button.image == UIImage(named: "fontsize"))
        #expect(button.target === subject)
        #expect(button.action == #selector(subject.doFontSize))
        #expect(button.tintColor == .myPurple)
        #expect(button.accessibilityLabel == "Font size")
        #expect(button.accessibilityHint == "Tap to change article font size.")
    }

    @Test("nextPrev segmented control is correctly constructed")
    func nextPrev() throws {
        let nextPrev = subject.nextPrev
        #expect(nextPrev.isMomentary == true)
        #expect(nextPrev.translatesAutoresizingMaskIntoConstraints == false)
        #expect(nextPrev.titleTextAttributes(for: .normal)?[.foregroundColor] as? UIColor == UIColor.myPurple)
        #expect(nextPrev.titleTextAttributes(for: .selected)?[.foregroundColor] as? UIColor == UIColor.white)
        #expect(nextPrev.titleTextAttributes(for: .disabled)?[.foregroundColor] as? UIColor == .clear)
        let constraint1 = nextPrev.constraints[0]
        #expect(constraint1.firstAttribute == .height)
        #expect(constraint1.constant == 34)
        #expect(constraint1.isActive)
        let constraint2 = nextPrev.constraints[1]
        #expect(constraint2.firstAttribute == .width)
        #expect(constraint2.constant == 126)
        #expect(constraint2.isActive)
        let action = nextPrev.actions(forTarget: subject, forControlEvent: .valueChanged)?.first
        #expect(action == "doNextPrev:")
        let color = try #require(nextPrev.backgroundColor)
        #expect(color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)) == UIColor.myPurple * 0.2 + UIColor.white * 0.8)
        #expect(color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)) == UIColor.myPurple * 0.8 + UIColor.black * 0.2)
        var image = try #require(nextPrev.imageForSegment(at: 0))
        #expect(image == UIImage(named: "prev"))
        #expect(image.accessibilityLabel == "Previous article")
        image = try #require(nextPrev.imageForSegment(at: 1))
        #expect(image == UIImage(named: "next"))
        #expect(image.accessibilityLabel == "Next article")
    }

    @Test("webView is correctly constructed")
    func webView() {
        let webView = subject.webView
        #expect(webView.configuration.suppressesIncrementalRendering == true)
        #expect(webView.allowsLinkPreview == false)
        #expect(webView.translatesAutoresizingMaskIntoConstraints == false)
        #expect(webView.navigationDelegate === subject)
    }

    @Test("viewDidLoad: constructs the interface")
    func viewDidLoad() async throws {
        subject.loadViewIfNeeded()
        #expect(subject.drawer.isDescendant(of: subject.view))
        #expect(subject.webView.isDescendant(of: subject.view))
        #expect(subject.navigationItem.titleView === subject.nextPrev)
        #expect(subject.navigationItem.rightBarButtonItem === subject.fontSizeButton)
    }

    @Test("viewDidLoad: background color is correct")
    func backgroundColor() throws {
        subject.loadViewIfNeeded()
        let color = try #require(subject.view.backgroundColor)
        #expect(color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)) == UIColor.myPurple * 0.4 + UIColor.white * 0.6)
        #expect(color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)) == UIColor.myPurple * 0.8 + UIColor.black * 0.2)
    }

    @Test("present: sets the drawer's attributedText")
    func presentDrawer() async {
        let webView = MockWebView()
        subject.webView = webView
        let state = DetailState(item: FeedItem(title: "Title", guid: "guid", blurb: "blurb"))
        await subject.present(state)
        #expect(subject.drawer.attributedText == state.item.attributedTitle)
    }

    @Test("present: loads web view with content string")
    func presentWebView() async {
        let webView = MockWebView()
        subject.webView = webView
        let state = DetailState(
            template: "template",
            templateURL: URL(string: "https://www.example.com")
        )
        await subject.present(state)
        #expect(webView.methodsCalled == ["loadHTMLString(_:baseURL:)"])
        #expect(webView.baseURL == URL(string: "https://www.example.com")!)
        #expect(webView.string == "template")
    }

    @Test("present: sets segmented control segment enablements based on state")
    func presentSegmentedControlEnablements() async {
        subject.loadViewIfNeeded()
        var item = FeedItem(guid: "guid", isFirst: false, isLast: false)
        await subject.present(DetailState(item: item))
        #expect(subject.nextPrev.isEnabledForSegment(at: 0) == true)
        #expect(subject.nextPrev.isEnabledForSegment(at: 1) == true)
        item = FeedItem(guid: "guid", isFirst: true, isLast: false)
        await subject.present(DetailState(item: item))
        #expect(subject.nextPrev.isEnabledForSegment(at: 0) == false)
        #expect(subject.nextPrev.isEnabledForSegment(at: 1) == true)
        item = FeedItem(guid: "guid", isFirst: false, isLast: true)
        await subject.present(DetailState(item: item))
        #expect(subject.nextPrev.isEnabledForSegment(at: 0) == true)
        #expect(subject.nextPrev.isEnabledForSegment(at: 1) == false)
    }

    @Test("receive newFontSize: evaluates js, changes accessibility value of button")
    func newFontSize() async {
        let webView = MockWebView()
        subject.webView = webView
        subject.loadViewIfNeeded()
        await subject.receive(.newFontSize("heyho", 42))
        #expect(webView.methodsCalled == ["evaluateJavaScript(_:)"])
        #expect(webView.js == "heyho")
        #expect(subject.fontSizeButton.accessibilityValue == "42")
    }

    @Test("doNextPrev: sends goNext/Prev depending on segment")
    func doNextPrev() async {
        let seg = UISegmentedControl(items: ["hey", "ho"])
        seg.selectedSegmentIndex = 0
        subject.doNextPrev(seg)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.goPrev])
        processor.thingsReceived = []
        seg.selectedSegmentIndex = 1
        subject.doNextPrev(seg)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.goNext])
    }

    @Test("doFontSize: sends changeFontSize")
    func doFontSize() async {
        subject.doFontSize(subject)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.changeFontSize])
    }

    @Test("doURL: sends doURL with URL")
    func doURL() async {
        let url = URL(string: "https://www.example.com")!
        subject.doURL(url)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.doURL(url)])
    }

    @Test("doTapTitle: sends tapTitle, toggles drawer background color")
    func doTapTitle() async {
        subject.loadViewIfNeeded()
        subject.doTapTitle()
        await #while(subject.drawer.backgroundColor != .systemYellow)
        #expect(subject.drawer.backgroundColor == .systemYellow)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.tapTitle])
        #expect(subject.drawer.backgroundColor == .systemBackground)
    }

    @Test("decidePolicy: for linkActivated sends doURL, returns cancel")
    func decidePolicyLinkActivated() async {
        subject.loadViewIfNeeded()
        let url = URL(string: "https://www.example.com")!
        let request = URLRequest(url: url)
        let action = MockNavigationAction(request: request, navigationType: .linkActivated)
        let result = await subject.webView(subject.webView, decidePolicyFor: action)
        #expect(result == .cancel)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.doURL(url)])
    }

    @Test("decidePolicy: for anything else returns allow")
    func decidePolicyOther() async {
        subject.loadViewIfNeeded()
        let url = URL(string: "https://www.example.com")!
        let request = URLRequest(url: url)
        let action = MockNavigationAction(request: request, navigationType: .other)
        let result = await subject.webView(subject.webView, decidePolicyFor: action)
        #expect(result == .allow)
        try? await Task.sleep(for: .seconds(0.1))
        #expect(processor.thingsReceived.isEmpty)
    }
}

private final class MockWebView: WKWebView {
    var methodsCalled = [String]()
    var string: String?
    var baseURL: URL?
    var js: String?

    override func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
        methodsCalled.append(#function)
        self.string = string
        self.baseURL = baseURL
        return nil
    }

    override func evaluateJavaScript(_ js: String) async throws -> Any? {
        methodsCalled.append(#function)
        self.js = js
        return nil
    }
}

private final class MockNavigationAction: WKNavigationAction {
    let myRequest: URLRequest
    let myNavigationType: WKNavigationType

    override var request: URLRequest { myRequest }
    override var navigationType: WKNavigationType { myNavigationType }

    init(request: URLRequest, navigationType: WKNavigationType) {
        self.myRequest = request
        self.myNavigationType = navigationType
        super.init()
    }
}
