@testable import TidBITSRSS26
import Testing

private struct DetailProcessorTests {
    let subject = DetailProcessor()
    let presenter = MockReceiverPresenter<Void, DetailState>()
    let bundle = MockBundle()

    init() {
        subject.presenter = presenter
        services.bundle = bundle
    }

    @Test("receive newState: sets state and presents it")
    func newState() async {
        let newState = DetailState(item: FeedItem(guid: "newguid"))
        await subject.receive(.newState(newState))
        #expect(subject.state.item.guid == "newguid")
        #expect(presenter.statesPresented.first?.item.guid == "newguid")
    }

    @Test("receive newState: fetches template from bundle, does substitutions, configures state with result, presents")
    func presentWebView() async {
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
        await subject.receive(.newState(state))
        #expect(bundle.methodsCalled == ["url(forResource:withExtension:)"])
        #expect(bundle.resource == "htmltemplate")
        #expect(bundle.ext == "txt")
        #expect(subject.state.contentString == """
        80% is 80%
        18 is 18
        <margin> is 5
        guid is guid
        Author is Author
        Content is Content
        https:// is https://
        10 August 1954 is 10 August 1954
        """)
        #expect(subject.state.templateURL == tempURL)
        #expect(presenter.statesPresented == [subject.state])
    }
}
