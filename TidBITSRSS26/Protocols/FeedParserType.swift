/// Protocol expressing the public face of FDPParser, so we can mock it for testing.
protocol FeedParserType: Sendable {
    static func parsedFeed(with: Data!) throws -> FDPFeed
}

extension FDPParser: FeedParserType {}

extension FDPFeed: @unchecked Sendable {}
