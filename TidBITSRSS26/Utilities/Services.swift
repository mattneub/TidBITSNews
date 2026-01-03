final class Services {
    var bundle: BundleType = Bundle.main
    var feedFetcher: FeedFetcherType = FeedFetcher()
    var feedParser: FeedParserType.Type = FDPParser.self
}
