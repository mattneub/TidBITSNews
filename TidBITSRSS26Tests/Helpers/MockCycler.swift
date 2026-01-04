@testable import TidBITSRSS26
import Foundation

final class MockCycler<ActionType, P: Processor>: Cycler<ActionType, P> where ActionType == P.Received {
    var thingsReceived = [ActionType]()
    override func receive(_ action: ActionType) async {
        thingsReceived.append(action)
    }
}
