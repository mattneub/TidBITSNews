@testable import TidBITSRSS26
import Testing
import UIKit
import WaitWhile

private struct MasterViewControllerTests {
    let subject = MasterViewController()
    let processor = MockProcessor<MasterAction, MasterState, Void>()

    init() {
        subject.processor = processor
    }

    @Test("viewDidAppear: sends processor viewDidAppear")
    func viewDidAppear() async {
        subject.viewDidAppear(false)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.viewDidAppear])
    }
}
