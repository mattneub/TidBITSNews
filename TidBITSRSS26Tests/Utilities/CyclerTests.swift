@testable import TidBITSRSS26
import Testing

private struct CyclerTests {
    @Test("receive passes to processor")
    func receive() async {
        let processor = MockProcessor<DetailAction, DetailState, DetailEffect>()
        let subject = Cycler(processor: processor)
        await subject.receive(.goNext)
        #expect(processor.thingsReceived == [.goNext])
    }
}
