@testable import TidBITSRSS26
import Testing

private struct DetailProcessorTests {
    let subject = DetailProcessor()
    let presenter = MockReceiverPresenter<DetailEffect, DetailState>()
    let delegate = MockDelegate()
    let bundle = MockBundle()
    let persistence = MockPersistence()
    let coordinator = MockRootCoordinator()

    init() {
        subject.presenter = presenter
        subject.delegate = delegate
        subject.coordinator = coordinator
        services.bundle = bundle
        services.persistence = persistence
    }

    @Test("receive changeFontSize: ups state font size, sends newFontSize with js")
    func changeFontSize() async {
        #expect(subject.state.fontSize == 18)
        await subject.receive(.changeFontSize)
        #expect(subject.state.fontSize == 20)
        #expect(persistence.methodsCalled == ["saveSize(_:)"])
        #expect(persistence.size == 20)
        let expectedJs = "document.body.style.fontSize='20px';'';"
        #expect(presenter.thingsReceived == [.newFontSize(expectedJs)])
        // cycles at 26
        subject.state.fontSize = 26
        await subject.receive(.changeFontSize)
        #expect(subject.state.fontSize == 12)
    }

    @Test("receive doURL: calls coordinator showURL")
    func doURL() async {
        let url = URL(string: "https://www.example.com")!
        await subject.receive(.doURL(url))
        #expect(coordinator.methodsCalled == ["showURL(_:)"])
        #expect(coordinator.url == url)
    }

    @Test("receive goNext: calls delegate goNext")
    func goNext() async {
        await subject.receive(.goNext)
        #expect(delegate.methodsCalled == ["goNext()"])
    }

    @Test("receive goPrev: calls delegate goPrev")
    func goPrev() async {
        await subject.receive(.goPrev)
        #expect(delegate.methodsCalled == ["goPrev()"])
    }

    @Test("receive newItem: sets item into state and presents it")
    func newItem() async {
        persistence.size = 23
        let newItem = FeedItem(guid: "newguid")
        await subject.receive(.newItem(newItem))
        #expect(subject.state.fontSize == 23)
        #expect(subject.state.item.guid == "newguid")
        #expect(presenter.statesPresented.first?.item.guid == "newguid")
        // when no size, 18 is used
        persistence.size = nil
        await subject.receive(.newItem(newItem))
        #expect(subject.state.fontSize == 18)
    }

    @Test("receive newItem: fetches template from bundle, configures state with result, presents")
    func presentWebView() async {
        let item = FeedItem(guid: "guid")
        let template = "template"
        let tempURL = URL.temporaryDirectory.appending(path: "template")
        bundle.urlToReturn = tempURL
        try? FileManager.default.removeItem(at: tempURL)
        try? template.write(to: tempURL, atomically: true, encoding: .utf8)
        await subject.receive(.newItem(item))
        #expect(bundle.methodsCalled == ["url(forResource:withExtension:)"])
        #expect(bundle.resource == "htmltemplate")
        #expect(bundle.ext == "txt")
        #expect(subject.state.item == item)
        #expect(subject.state.template == "template")
        #expect(subject.state.templateURL == tempURL)
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive tapTitle: calls coordinator showURL with feed item url")
    func tapTitle() async {
        subject.state.item.url = URL(string: "https://www.example.com")!
        await subject.receive(.tapTitle)
        #expect(coordinator.methodsCalled == ["showURL(_:)"])
        #expect(coordinator.url == URL(string: "https://www.example.com")!)
    }
}

private final class MockDelegate: DetailProcessorDelegate {
    var methodsCalled = [String]()

    func goNext() async {
        methodsCalled.append(#function)
    }
    func goPrev() async {
        methodsCalled.append(#function)
    }
}
