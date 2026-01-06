@testable import TidBITSRSS26

final class MockFeedFetcher: FeedFetcherType {
    var methodsCalled = [String]()
    var network: Bool?
    var fetchResultToReturn: FetchResult?
    var errorToThrow: Error?

    func fetchFeed(_ network: Bool) async throws -> FetchResult? {
        methodsCalled.append(#function)
        self.network = network
        if let errorToThrow {
            throw errorToThrow
        }
        return fetchResultToReturn
    }
}
