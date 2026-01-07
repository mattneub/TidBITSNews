final class Services {
    var bundle: BundleType = Bundle.main
    var feedFetcher: FeedFetcherType = FeedFetcher()
    var feedParser: FeedParserType.Type = FDPParser.self
    var persistence: PersistenceType = Persistence()
    var safariProvider: SafariProviderType = SafariProvider()
    var userDefaults: UserDefaultsType = UserDefaults.standard
}
