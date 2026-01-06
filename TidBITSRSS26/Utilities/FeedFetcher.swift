/// Protocol expressing the public face of our FeedFetcher, so we can mock it for testing.
protocol FeedFetcherType {
    /// Fetch the feed from persistence or network (or, if developing, from the bundle).
    /// - Parameter network: A Bool stating whether to force use of the network.
    /// - Returns: A FetchResult object, or nil if things didn't work out.
    func fetchFeed(_ network: Bool) async throws -> FetchResult?
}

extension FeedFetcherType {
    func fetchFeed() async throws -> FetchResult? {
        try await fetchFeed(false)
    }
}

/// Service type that decides how to obtain the feed, obtains it, and parses it.
final class FeedFetcher: FeedFetcherType {
    func fetchFeed(_ network: Bool) async throws -> FetchResult? {
        guard let (items, fetchType) = try await reallyFetchFeed(network) else {
            return nil
        }
        return FetchResult(
            items: items,
            type: fetchType
        )
    }

    /// Session to be used if we have to do actual networking; it's a var so we can mock it for testing.
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = false // fail now if you can't connect, please
        let session = URLSession(configuration: configuration)
        return session
    }()

    @concurrent
    func reallyFetchFeed(_ network: Bool) async throws -> ([FeedItem], FetchType)? {
        #if targetEnvironment(simulator)
        if await unlessTesting(true) && ProcessInfo.processInfo.environment["LOADLOCAL"] != nil {
            if let url = Bundle.main.url(forResource: "feed", withExtension: "txt") {
                let data = try Data(contentsOf: url)
                let feed = try await services.feedParser.parsedFeed(with: data)
                return (feed.toFeedItems, .bundle)
            } else { // no url
                return nil
            }
        }
        #endif
        if !network, let items = await services.persistence.loadFeed() {
            return(items, .persistence)
        }
        if let url = URL(string: "https://tidbits.com/feeds/app_feed.rss") {
            let request = URLRequest(url: url)
            let (data, _) = try await session.data(for: request)
            let feed = try await services.feedParser.parsedFeed(with: data)
            let items = feed.toFeedItems
            await services.persistence.saveFeed(items)
            return (items, .network)
        }
        return nil
    }
}

enum FetchType {
    case bundle
    case network
    case persistence
}

/// Result type of `fetchFeed`, consisting of a list of FeedItem reducer objects plus a statement
/// of _how_ this fetch was performed, i.e. from the network or from persistent storage.
struct FetchResult {
    let items: [FeedItem]
    let type: FetchType
}

