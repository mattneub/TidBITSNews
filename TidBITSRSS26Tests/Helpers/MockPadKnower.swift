@testable import TidBITSRSS26

final class MockPadKnower: PadKnowerType {
    var methodsCalled = [String]()
    var boolToReturn = false

    func isPad() -> Bool {
        methodsCalled.append(#function)
        return boolToReturn
    }
}
