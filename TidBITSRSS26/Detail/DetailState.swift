import Foundation

struct DetailState: Equatable {
    var contentString: String = ""
    var item = FeedItem(guid: "dummy")
    var templateURL: URL?
}
