@testable import TidBITSRSS26
import Foundation

nonisolated
final class MockFDPItem: FDPItem {
    var _guid: String = ""
    var _title: String = ""
    var _pubDate: Date = Date.now
    var _content: String = ""

    override var guid: String { _guid }
    override var title: String { _title }
    override var pubDate: Date { _pubDate }
    override var content: String { _content }
}
