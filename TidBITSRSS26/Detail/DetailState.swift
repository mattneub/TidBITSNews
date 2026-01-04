import Foundation

struct DetailState: Equatable {
    var contentString: String = ""
    var fontSize: Int = 18
    var item = FeedItem(guid: "dummy")
    var templateURL: URL?
}
