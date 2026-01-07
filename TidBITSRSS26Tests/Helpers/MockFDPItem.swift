@testable import TidBITSRSS26
import Foundation

nonisolated
final class MockFDPItem: FDPItem {
    var _guid: String = ""
    var _title: String = ""
    var _pubDate: Date = Date.now
    var _content: String = ""
    var _link: FDPLink = MockFDPLink()

    override var guid: String { _guid }
    override var title: String { _title }
    override var pubDate: Date { _pubDate }
    override var content: String { _content }
    override var link: FDPLink { _link }
}

nonisolated
final class MockFDPLink: FDPLink {
    var _href: String = "href"
    override var href: String { _href }
}
