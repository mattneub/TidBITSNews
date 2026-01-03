@testable import TidBITSRSS26
import Testing

private struct DetailProcessorTests {
    let subject = DetailProcessor()
    let presenter = MockReceiverPresenter<Void, DetailState>()

    init() {
        subject.presenter = presenter
    }

    @Test("receive initialData: presents state")
    func initialData() async {
        subject.state.item = FeedItem(guid: "guid")
        await subject.receive(.initialData)
        #expect(presenter.statesPresented == [DetailState(item: FeedItem(guid: "guid"))])
    }
}
