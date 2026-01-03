@testable import TidBITSRSS26
import Testing
import UIKit
import WebKit
import WaitWhile

private struct MDetailiewControllerTests {
    let subject = DetailViewController()
    let processor = MockProcessor<DetailAction, DetailState, Void>()
    let bundle = MockBundle()

    init() {
        subject.processor = processor
        services.bundle = bundle
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

    @Test("viewDidLoad: constructs the interface, sends initialData")
    func viewDidLoad() async {
        subject.loadViewIfNeeded()
        #expect(subject.drawer.isDescendant(of: subject.view))
        #expect(subject.webView.isDescendant(of: subject.view))
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.initialData])
    }

    @Test("present: sets the drawer's attributedText")
    func presentDrawer() async {
        let webView = MockWebView()
        subject.webView = webView
        let state = DetailState(item: FeedItem(title: "Title", guid: "guid", blurb: "blurb"))
        await subject.present(state)
        #expect(subject.drawer.attributedText == state.item.attributedTitle)
    }

    @Test("present: fetches template from bundle, does substitutions, loads web view with result")
    func presentWebView() async {
        let webView = MockWebView()
        subject.webView = webView
        let dateComponents = DateComponents(calendar: .init(identifier: .gregorian), year: 1954, month: 8, day: 10)
        let date = dateComponents.date!
        let state = DetailState(
            item: FeedItem(
                title: "Title",
                guid: "guid",
                blurb: "blurb",
                author: "Author",
                pubDate: date,
                content: "Content"
            )
        )
        let template = """
        <maximagewidth> is 80%
        <fontsize> is 18
        <margin> is 5
        <guid> is guid
        <author> is Author
        <content> is Content
        http:// is https://
        <date> is 10 August 1954
        """
        let tempURL = URL.temporaryDirectory.appending(path: "template")
        bundle.urlToReturn = tempURL
        try? FileManager.default.removeItem(at: tempURL)
        try? template.write(to: tempURL, atomically: true, encoding: .utf8)
        await subject.present(state)
        #expect(bundle.methodsCalled == ["url(forResource:withExtension:)"])
        #expect(bundle.resource == "htmltemplate")
        #expect(bundle.ext == "txt")
        #expect(webView.methodsCalled == ["loadHTMLString(_:baseURL:)"])
        #expect(webView.baseURL == tempURL)
        #expect(webView.string == """
        80% is 80%
        18 is 18
        5 is 5
        guid is guid
        Author is Author
        Content is Content
        https:// is https://
        10 August 1954 is 10 August 1954
        """)
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
