@testable import TidBITSRSS26

nonisolated
final class MockFDPFeed: FDPFeed {
    var _items = Array<Any>()
    override var items: Array<Any> { _items }
}

