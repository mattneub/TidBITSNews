/// Reducer used to move feed item information around the app.
struct FeedItem: Equatable {
    let title: String
    let guid: String
}

extension FeedItem {
    init(fdpItem item: FDPItem) {
        self.title = item.title
        self.guid = item.guid
    }
}
