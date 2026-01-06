@testable import TidBITSRSS26
import Testing

private struct MasterProcessorTests {
    let subject = MasterProcessor()
    let presenter = MockReceiverPresenter<MasterEffect, MasterState>()
    let feedFetcher = MockFeedFetcher()
    let coordinator = MockRootCoordinator()
    let cycler: MockCycler<MasterAction, MasterProcessor>!

    init() {
        subject.presenter = presenter
        subject.coordinator = coordinator
        cycler = MockCycler(processor: subject)
        subject.cycler = cycler
        services.feedFetcher = feedFetcher
    }

    @Test("receive appearing: sends reloadTable")
    func appearing() async {
        await subject.receive(.appearing)
        #expect(presenter.thingsReceived == [.reloadTable])
    }

    @Test("receive fetchFeed: calls feed parser fetchFeed, sets state parsedData, presents it")
    func fetchFeed() async {
        let item0 = FeedItem(guid: "testing0")
        let item1 = FeedItem(guid: "testing1")
        feedFetcher.fetchResultToReturn = FetchResult(items: [item0, item1], type: .persistence)
        await subject.receive(.fetchFeed(forceNetwork: false))
        #expect(feedFetcher.methodsCalled == ["fetchFeed(_:)"])
        #expect(feedFetcher.network == false)
        #expect(subject.state.parsedData == [item0, item1])
        #expect(presenter.statesPresented == [subject.state])
        // and again, with true instead of false
        presenter.statesPresented = []
        feedFetcher.methodsCalled = []
        await subject.receive(.fetchFeed(forceNetwork: true))
        #expect(feedFetcher.methodsCalled == ["fetchFeed(_:)"])
        #expect(feedFetcher.network == true)
        #expect(subject.state.parsedData == [item0, item1])
        #expect(subject.state.lastNetworkFetchDate == nil)
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive fetchFeed: updates feed items' hasBeenRead according to guids set")
    func fetchFeedHasBeenRead() async {
        let item0 = FeedItem(guid: "testing0")
        let item1 = FeedItem(guid: "testing1")
        feedFetcher.fetchResultToReturn = FetchResult(items: [item0, item1], type: .persistence)
        subject.state.guidsOfReadItems = ["testing1"]
        await subject.receive(.fetchFeed(forceNetwork: false))
        #expect(subject.state.parsedData[0].hasBeenRead == false)
        #expect(subject.state.parsedData[1].hasBeenRead == true)
        #expect(subject.state.lastNetworkFetchDate == nil)
    }

    @Test("receive fetchFeed: sets state lastNetworkFetchDate, only if result type is network")
    func fetchFeedNetworkingDate() async {
        let item0 = FeedItem(guid: "testing0")
        let item1 = FeedItem(guid: "testing1")
        feedFetcher.fetchResultToReturn = FetchResult(items: [item0, item1], type: .network) // *
        subject.state.guidsOfReadItems = ["testing1"]
        await subject.receive(.fetchFeed(forceNetwork: false))
        #expect(subject.state.lastNetworkFetchDate != nil) // *
    }

    @Test("receive fetchFeed: presents even if the call to feed fetcher throws")
    func fetchFeedThrow() async {
        #expect(presenter.statesPresented.isEmpty)
        enum Oops: Error { case ouch }
        feedFetcher.errorToThrow = Oops.ouch
        await subject.receive(.fetchFeed(forceNetwork: false))
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive selected: calls coordinator showDetail with configured feed item for row, updates guids, state feed item")
    func selected() async {
        let item0 = FeedItem(guid: "testing0")
        let item1 = FeedItem(guid: "testing1")
        subject.state.parsedData = [item0, item1]
        await subject.receive(.selected(0))
        #expect(coordinator.methodsCalled == ["showDetail(item:)"])
        #expect(coordinator.feedItem?.guid == "testing0")
        #expect(coordinator.feedItem?.isFirst == true)
        #expect(coordinator.feedItem?.isLast == false)
        #expect(subject.state.guidsOfReadItems.contains("testing0"))
        #expect(subject.state.parsedData[0].hasBeenRead == true)
        coordinator.methodsCalled = []
        await subject.receive(.selected(1))
        #expect(coordinator.methodsCalled == ["showDetail(item:)"])
        #expect(coordinator.feedItem?.guid == "testing1")
        #expect(coordinator.feedItem?.isFirst == false)
        #expect(coordinator.feedItem?.isLast == true)
        #expect(subject.state.guidsOfReadItems.contains("testing1"))
        #expect(subject.state.parsedData[1].hasBeenRead == true)
    }

    @Test("receive updateHasBeenRead: updates guids, state feed item")
    func updateHasBeenRead() async {
        let item0 = FeedItem(guid: "testing0")
        let item1 = FeedItem(guid: "testing1")
        subject.state.parsedData = [item0, item1]
        await subject.receive(.updateHasBeenRead(true, for: 1))
        #expect(subject.state.guidsOfReadItems.contains("testing1"))
        #expect(subject.state.parsedData[1].hasBeenRead == true)
        await subject.receive(.updateHasBeenRead(false, for: 1))
        #expect(!subject.state.guidsOfReadItems.contains("testing1"))
        #expect(subject.state.parsedData[1].hasBeenRead == false)
    }

    @Test("viewDidAppear: if state parsed data is empty, sends cycler fetchFeed")
    func viewDidAppear() async {
        await subject.receive(.viewDidAppear)
        #expect(cycler.thingsReceived == [.fetchFeed(forceNetwork: false)])
    }

    @Test("viewDidAppear: if state parsed data is not empty, does nothing")
    func viewDidAppearNotEmpty() async {
        let item = FeedItem(title: "Testing", guid: "testing")
        subject.state.parsedData = [item]
        await subject.receive(.viewDidAppear)
        #expect(cycler.thingsReceived.isEmpty)
    }

    @Test("goNext: if can add 1 to state selected item index, does so, sends cycler selected and presenter select")
    func goNext() async {
        let item0 = FeedItem(guid: "testing0")
        let item1 = FeedItem(guid: "testing1")
        subject.state.parsedData = [item0, item1]
        await subject.goNext()
        #expect(cycler.thingsReceived.isEmpty) // because there is no selection
        #expect(presenter.thingsReceived.isEmpty)
        subject.state.selectedItemIndex = 0
        await subject.goNext()
        #expect(cycler.thingsReceived == [.selected(1)])
        #expect(presenter.thingsReceived == [.select(1)])
        cycler.thingsReceived = []
        presenter.thingsReceived = []
        subject.state.selectedItemIndex = 1 // the processor would do this when called by cycler
        await subject.goNext()
        #expect(cycler.thingsReceived.isEmpty) // because we've reached the limit
        #expect(presenter.thingsReceived.isEmpty)
    }

    @Test("goPrev: if can subtract 1 from state selected item index, does so, sends cycler selected and presenter select")
    func goPrev() async {
        let item0 = FeedItem(guid: "testing0")
        let item1 = FeedItem(guid: "testing1")
        subject.state.parsedData = [item0, item1]
        await subject.goPrev()
        #expect(cycler.thingsReceived.isEmpty) // because there is no selection
        #expect(presenter.thingsReceived.isEmpty)
        subject.state.selectedItemIndex = 1
        await subject.goPrev()
        #expect(cycler.thingsReceived == [.selected(0)])
        #expect(presenter.thingsReceived == [.select(0)])
        cycler.thingsReceived = []
        presenter.thingsReceived = []
        subject.state.selectedItemIndex = 0 // the processor would do this when called by cycler
        await subject.goPrev()
        #expect(cycler.thingsReceived.isEmpty) // because we've reached the limit
        #expect(presenter.thingsReceived.isEmpty)
    }
}
