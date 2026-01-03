@testable import TidBITSRSS26
import Testing

private struct MasterProcessorTests {
    let subject = MasterProcessor()
    let presenter = MockReceiverPresenter<Void, MasterState>()
    let feedFetcher = MockFeedFetcher()
    let coordinator = MockRootCoordinator()

    init() {
        subject.presenter = presenter
        subject.coordinator = coordinator
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
        let item = FeedItem(title: "Testing", guid: "testing")
        subject.state.parsedData = [item]
        await subject.receive(.viewDidAppear)
        #expect(feedFetcher.methodsCalled.isEmpty)
        #expect(subject.state.parsedData == [item])
        #expect(presenter.statesPresented.isEmpty)
    }

    @Test("selected: calls coordinator showDetail with feed item corresponding to row")
    func selected() async {
        let item0 = FeedItem(guid: "testing0")
        let item1 = FeedItem(guid: "testing1")
        subject.state.parsedData = [item0, item1]
        await subject.receive(.selected(1))
        #expect(coordinator.methodsCalled == ["showDetail(state:)"])
        #expect(coordinator.detailState == DetailState(item: item1))
    }
}
