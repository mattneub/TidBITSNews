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
    func drawer() {
        let drawer = subject.drawer
        #expect(drawer.translatesAutoresizingMaskIntoConstraints == false)
        #expect(drawer.numberOfLines == 0)
        #expect(subject.drawer.adjustsFontForContentSizeCategory == true)
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
        #expect(nextPrev.backgroundColor == .myPurple * 0.2 + .white * 0.8)
    }

    @Test("webView is correctly constructed")
    func webView() {
        let webView = subject.webView
        #expect(webView.configuration.suppressesIncrementalRendering == true)
        #expect(webView.allowsLinkPreview == false)
        #expect(webView.translatesAutoresizingMaskIntoConstraints == false)
    }

    @Test("viewDidLoad: constructs the interface")
    func viewDidLoad() async throws {
        subject.loadViewIfNeeded()
        #expect(subject.drawer.isDescendant(of: subject.view))
        #expect(subject.webView.isDescendant(of: subject.view))
        #expect(subject.navigationItem.titleView === subject.nextPrev)
        let button = try #require(subject.navigationItem.rightBarButtonItem)
        #expect(button.image == UIImage(named: "fontsize"))
        #expect(button.target === subject)
        #expect(button.action == #selector(subject.doFontSize))
        #expect(button.tintColor == .myPurple)
    }

    @Test("present: sets the drawer's attributedText")
    func presentDrawer() async {
        let webView = MockWebView()
        subject.webView = webView
        let state = DetailState(item: FeedItem(title: "Title", guid: "guid", blurb: "blurb"))
        await subject.present(state)
        #expect(subject.drawer.attributedText == state.item.attributedTitle)
    }

    @Test("present: does substitution on contentString, loads web view with result")
    func presentWebView() async {
        subject.traitOverrides.userInterfaceIdiom = .phone
        let webView = MockWebView()
        subject.webView = webView
        let state = DetailState(
            contentString: "<margin> is 5",
            item: FeedItem(
                title: "Title",
                guid: "guid",
                blurb: "blurb",
                author: "Author",
                pubDate: Date.distantPast,
                content: "Content"
            ),
            templateURL: URL(string: "https://www.example.com")
        )
        await subject.present(state)
        #expect(webView.methodsCalled == ["loadHTMLString(_:baseURL:)"])
        #expect(webView.baseURL == URL(string: "https://www.example.com")!)
        #expect(webView.string == "5 is 5")
    }

    @Test("present: does substitution on contentString, loads web view with result, iPad version")
    func presentWebViewPad() async {
        subject.traitOverrides.userInterfaceIdiom = .pad
        let webView = MockWebView()
        subject.webView = webView
        let state = DetailState(
            contentString: "<margin> is 20",
            item: FeedItem(
                title: "Title",
                guid: "guid",
                blurb: "blurb",
                author: "Author",
                pubDate: Date.distantPast,
                content: "Content"
            ),
            templateURL: URL(string: "https://www.example.com")
        )
        await subject.present(state)
        #expect(webView.methodsCalled == ["loadHTMLString(_:baseURL:)"])
        #expect(webView.baseURL == URL(string: "https://www.example.com")!)
        #expect(webView.string == "20 is 20")
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
}

private final class MockWebView: WKWebView {
    var methodsCalled = [String]()
    var string: String?
    var baseURL: URL?

    override func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
        methodsCalled.append(#function)
        self.string = string
        self.baseURL = baseURL
        return nil
    }
}
