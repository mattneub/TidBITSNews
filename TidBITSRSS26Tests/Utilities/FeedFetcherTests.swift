@testable import TidBITSRSS26
import Testing
import WaitWhile

private struct FeedFetcherTests {
    let subject = FeedFetcher()

    static var session: URLSession = {
        let configuration: URLSessionConfiguration = .ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }()

    init() {
        services.feedParser = MockFeedParser.self
        MockFeedParser.prepare()
        subject.session = Self.session
    }

    @Test("subject's native session configuration is correct")
    func subjectSession() {
        let subject = FeedFetcher()
        let session = subject.session
        let configuration = session.configuration
        #expect(configuration.requestCachePolicy == .reloadIgnoringLocalCacheData)
        #expect(configuration.timeoutIntervalForResource == 60)
        #expect(configuration.waitsForConnectivity == false)
    }

    @Test("fetchFeed: makes correct request")
    func fetchFeedRequest() async throws {
        nonisolated(unsafe) var madeRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            madeRequest = request
            return (URLResponse(), Data())
        }
        _ = try? await subject.fetchFeed()
        #expect(madeRequest?.url == URL(string: "https://tidbits.com/feeds/app_feed.rss")!)
    }

    @Test("fetchFeed: calls parser, returns result items")
    func fetchFeedParser() async throws {
        MockURLProtocol.requestHandler = { request in
            return (URLResponse(), "howdy".data(using: .utf8)!)
        }
        let feed = MockFDPFeed()
        let item = MockFDPItem()
        item._guid = "testing"
        item._title = "title"
        item._pubDate = Date.distantPast
        feed._items = [item]
        MockFeedParser.feedToReturn = feed
        let result = try? await subject.fetchFeed()
        #expect(MockFeedParser.methodsCalled == ["parsedFeed(with:)"])
        #expect(MockFeedParser.data == "howdy".data(using: .utf8))
        #expect(result == [FeedItem(title: "title", guid: "testing")])
    }
}
