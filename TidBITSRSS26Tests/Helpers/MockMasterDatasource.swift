@testable import TidBITSRSS26

final class MockMasterDatasource: NSObject, @MainActor MasterDatasourceType {
    typealias State = MasterState
    typealias Received = MasterEffect

    var state: MasterState?
    var methodsCalled = [String]()
    var thingsReceived = [MasterEffect]()

    func present(_ state: MasterState) async {
        methodsCalled.append(#function)
        self.state = state
    }

    func receive(_ effect: MasterEffect) async {
        thingsReceived.append(effect)
    }

}
