@testable import TidBITSRSS26
import Testing
import WaitWhile

private struct FeedFetcherTests {
    let subject = FeedFetcher()
    let persistence = MockPersistence()

    nonisolated func sessionProvider() -> URLSession {
        let configuration: URLSessionConfiguration = .ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    init() {
        services.feedParser = MockFeedParser.self
        services.persistence = persistence
        MockFeedParser.prepare()
        subject.sessionProvider = sessionProvider
    }

    @Test("subject's native session configuration is correct")
    func subjectSession() {
        let subject = FeedFetcher()
        let session = subject.sessionProvider()
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

    @Test("fetchFeed: if persistence is empty, networks, calls parser, saves feed, returns result")
    func fetchFeedPersistenceEmpty() async throws {
        persistence.feed = nil
        MockURLProtocol.requestHandler = { request in
            return (URLResponse(), "howdy".data(using: .utf8)!)
        }
        let feed = MockFDPFeed()
        let item = MockFDPItem()
        item._guid = "testing"
        item._title = "title"
        item._pubDate = Date.distantPast
        let link = MockFDPLink()
        link._href = "http://www.example.com"
        item._link = link
        feed._items = [item]
        MockFeedParser.feedToReturn = feed
        let result = try? await subject.fetchFeed()
        #expect(persistence.methodsCalled == ["loadFeed()", "saveFeed(_:)"])
        #expect(persistence.feed == [FeedItem(title: "title", guid: "testing", url: URL(string: "http://www.example.com"))])
        #expect(MockFeedParser.methodsCalled == ["parsedFeed(with:)"])
        #expect(MockFeedParser.data == "howdy".data(using: .utf8))
        #expect(result?.items == [FeedItem(title: "title", guid: "testing", url: URL(string: "http://www.example.com"))])
        #expect(result?.type == .network)
    }

    @Test("fetchFeed: if persistence is not empty, does not network, does not call parser, returns result")
    func fetchFeedPersistenceNotEmpty() async throws {
        persistence.feed = [FeedItem(title: "title", guid: "testing2")] // *
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
        #expect(persistence.methodsCalled == ["loadFeed()"]) // *
        #expect(MockFeedParser.methodsCalled.isEmpty) // *
        #expect(MockFeedParser.data == nil)
        #expect(result?.items == [FeedItem(title: "title", guid: "testing2")])
        #expect(result?.type == .persistence) // *
    }

    @Test("fetchFeed: if persistence is not empty but force networking, networks, calls parser, returns result")
    func fetchFeedPersistenceNotEmptyForceNetworking() async throws {
        persistence.feed = [FeedItem(title: "title", guid: "testing2")] // *
        MockURLProtocol.requestHandler = { request in
            return (URLResponse(), "howdy".data(using: .utf8)!)
        }
        let feed = MockFDPFeed()
        let item = MockFDPItem()
        item._guid = "testing"
        item._title = "title"
        item._pubDate = Date.distantPast
        let link = MockFDPLink()
        link._href = "http://www.example.com"
        item._link = link
        feed._items = [item]
        MockFeedParser.feedToReturn = feed
        let result = try? await subject.fetchFeed(true) // *
        #expect(persistence.methodsCalled == ["saveFeed(_:)"]) // *
        #expect(persistence.feed == [FeedItem(title: "title", guid: "testing", url: URL(string: "http://www.example.com"))])
        #expect(MockFeedParser.methodsCalled == ["parsedFeed(with:)"])
        #expect(MockFeedParser.data == "howdy".data(using: .utf8))
        #expect(result?.items == [FeedItem(title: "title", guid: "testing", url: URL(string: "http://www.example.com"))])
        #expect(result?.type == .network)
    }
}
