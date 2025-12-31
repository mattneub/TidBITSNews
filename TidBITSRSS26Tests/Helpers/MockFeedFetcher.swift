@testable import TidBITSRSS26
import Testing

final class MockFeedFetcher: FeedFetcherType {
    var methodsCalled = [String]()
    var itemsToReturn = [FDPItem()]

    func fetchFeed() async throws -> [FDPItem] {
        methodsCalled.append(#function)
        return itemsToReturn
    }
}
