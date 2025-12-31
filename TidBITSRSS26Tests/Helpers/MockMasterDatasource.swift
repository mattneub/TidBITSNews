@testable import TidBITSRSS26
import Testing

final class MockMasterDatasource: NSObject, @MainActor MasterDatasourceType {
    typealias State = MasterState
    typealias Received = Void

    var state: MasterState?
    var methodsCalled = [String]()

    func present(_ state: MasterState) async {
        methodsCalled.append(#function)
        self.state = state
    }

}
