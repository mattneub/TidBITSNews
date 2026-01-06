/// Extension on FDPFeed that forms the crucial link between an FDPFeed and an array of FeedItem.
nonisolated extension FDPFeed {
    var toFeedItems: [FeedItem] {
        (items as? [FDPItem] ?? []).map(FeedItem.init)
    }
}

