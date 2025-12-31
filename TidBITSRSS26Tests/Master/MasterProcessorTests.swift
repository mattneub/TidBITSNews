@testable import TidBITSRSS26
import Testing

private struct MasterProcessorTests {
    let subject = MasterProcessor()
    let presenter = MockReceiverPresenter<Void, MasterState>()
    let feedFetcher = MockFeedFetcher()

    init() {
        subject.presenter = presenter
        services.feedFetcher = feedFetcher
    }

    @Test("viewDidAppear: if state parsed data is empty, asks fetcher to fetch it, presents it")
    func viewDidAppear() async {
        await subject.receive(.viewDidAppear)
        #expect(feedFetcher.methodsCalled == ["fetchFeed()"])
        #expect(subject.state.parsedData == feedFetcher.itemsToReturn)
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("viewDidAppear: if state parsed data is not empty, does nothing")
    func viewDidAppearNotEmpty() async {
        let item = FDPItem()
        subject.state.parsedData = [item]
        await subject.receive(.viewDidAppear)
        #expect(feedFetcher.methodsCalled.isEmpty)
        #expect(subject.state.parsedData == [item])
        #expect(presenter.statesPresented.isEmpty)
    }

}
