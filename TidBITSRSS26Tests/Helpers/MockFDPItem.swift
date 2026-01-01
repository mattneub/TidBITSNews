@testable import TidBITSRSS26

nonisolated
final class MockFDPItem: FDPItem {
    var _guid: String = ""
    var _title: String = ""
    override var guid: String { _guid }
    override var title: String { _title }
}
