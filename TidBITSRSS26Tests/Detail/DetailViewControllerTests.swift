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
    }

    @Test("webView is correctly constructed")
    func webView() {
        let webView = subject.webView
        #expect(webView.configuration.suppressesIncrementalRendering == true)
        #expect(webView.allowsLinkPreview == false)
        #expect(webView.translatesAutoresizingMaskIntoConstraints == false)
    }

    @Test("viewDidLoad: constructs the interface")
    func viewDidLoad() async {
        subject.loadViewIfNeeded()
        #expect(subject.drawer.isDescendant(of: subject.view))
        #expect(subject.webView.isDescendant(of: subject.view))
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
