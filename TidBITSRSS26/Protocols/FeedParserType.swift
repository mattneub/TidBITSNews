/// Protocol expressing the public face of FDPParser, so we can mock it for testing.
protocol FeedParserType: Sendable {
    nonisolated static func parsedFeed(with: Data!) throws -> FDPFeed
}

extension FDPParser: FeedParserType {}
