/// Protocol expressing the public face of our FeedFetcher, so we can mock it for testing.
protocol FeedFetcherType {
    func fetchFeed() async throws -> [FDPItem]
}

/// Service type that decides how to obtain the feed, obtains it, and parses it.
final class FeedFetcher: FeedFetcherType {
    /// Fetch the feed, parse it, and return its list of items.
    /// - Returns: The list of items.
    func fetchFeed() async throws -> [FDPItem] {
        let items = try await reallyFetchFeed()?.items as? [FDPItem]
        return items ?? []
    }

    /// Session to be used if we have to do actual networking; it's a var so we can mock for testing.
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = false // fail now if you can't connect, please
        let session = URLSession(configuration: configuration)
        return session
    }()

    @concurrent
    func reallyFetchFeed() async throws -> FDPFeed? {
        #if targetEnvironment(simulator)
        if await unlessTesting(true) && ProcessInfo.processInfo.environment["LOADLOCAL"] != nil {
            if let url = Bundle.main.url(forResource: "feed", withExtension: "txt") {
                let data = try Data(contentsOf: url)
                let result = try await services.feedParser.parsedFeed(with: data)
                return result
            } else { // no url
                return nil
            }
        }
        #endif
        // TODO: If there is a saved feed, fetch it, parse it, and return the result
        if let url = URL(string: "https://tidbits.com/feeds/app_feed.rss") {
            let request = URLRequest(url: url)
            let (data, _) = try await session.data(for: request)
            let result = try await services.feedParser.parsedFeed(with: data)
            return result
        }
        return nil
    }
}
