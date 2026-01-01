@testable import TidBITSRSS26

final class MockFeedFetcher: FeedFetcherType {
    var methodsCalled = [String]()
    var itemsToReturn: [FeedItem] = []

    func fetchFeed() async throws -> [FeedItem] {
        methodsCalled.append(#function)
        return itemsToReturn
    }
}
