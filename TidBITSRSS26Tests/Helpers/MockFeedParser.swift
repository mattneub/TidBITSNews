@testable import TidBITSRSS26

final class MockFeedParser: FeedParserType {
    nonisolated(unsafe) static var data: Data?
    nonisolated(unsafe) static var methodsCalled = [String]()
    nonisolated(unsafe) static var feedToReturn: FDPFeed!

    static func prepare() {
        data = nil
        methodsCalled = []
        feedToReturn = FDPFeed()
    }

    static func parsedFeed(with data: Data!) throws -> FDPFeed {
        methodsCalled.append(#function)
        self.data = data
        return feedToReturn
    }
}
