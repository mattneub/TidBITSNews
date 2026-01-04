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

    @Test("viewDidAppear: if state parsed data is empty, asks fetcher to fetch it, presents it")
    func viewDidAppear() async {
        let item0 = FeedItem(guid: "testing0")
        let item1 = FeedItem(guid: "testing1")
        feedFetcher.itemsToReturn = [item0, item1]
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

    @Test("viewDidAppear: configures parsed data hasBeenRead according to state guids")
    func viewDidAppearHasBeenRead() async {
        let item0 = FeedItem(guid: "testing0")
        let item1 = FeedItem(guid: "testing1")
        feedFetcher.itemsToReturn = [item0, item1]
        subject.state.guidsOfReadItems = ["testing1"]
        await subject.receive(.viewDidAppear)
        #expect(subject.state.parsedData[0].hasBeenRead == false)
        #expect(subject.state.parsedData[1].hasBeenRead == true)
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
