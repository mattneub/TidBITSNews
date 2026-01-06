@testable import TidBITSRSS26
import Testing
import Foundation

private struct PersistenceTests {
    let subject = Persistence()
    let defaults = MockUserDefaults()

    init() {
        services.userDefaults = defaults
    }

    @Test func saveFeed() throws {
        subject.saveFeed([FeedItem(guid: "guid")])
        #expect(defaults.methodsCalled == ["set(_:forKey:)"])
        let data = try #require(defaults.sets["feeditems"] as? Data)
        let result = try PropertyListDecoder().decode(Persistence.Wrapper<[FeedItem]>.self, from: data).value
        #expect(result == [FeedItem(guid: "guid")])
    }

    @Test func loadFeed() throws {
        let data = try PropertyListEncoder().encode(Persistence.Wrapper(value: [FeedItem(guid: "guid")]))
        defaults.gets["feeditems"] = data
        let result = subject.loadFeed()
        #expect(result == [FeedItem(guid: "guid")])
    }

    @Test func loadFeedFail() throws {
        let result = subject.loadFeed()
        #expect(result == nil)
    }

    @Test func saveReadGuids() throws {
        subject.saveReadGuids(["guid"])
        #expect(defaults.methodsCalled == ["set(_:forKey:)"])
        let data = try #require(defaults.sets["readitems"] as? Data)
        let result = try PropertyListDecoder().decode(Persistence.Wrapper<Set<String>>.self, from: data).value
        #expect(result == ["guid"])
    }

    @Test func loadReadGuids() throws {
        let data = try PropertyListEncoder().encode(Persistence.Wrapper(value: Set(["guid"])))
        defaults.gets["readitems"] = data
        let result = subject.loadReadGuids()
        #expect(result == Set(["guid"]))
    }

    @Test func loadReadGuidsFail() throws {
        let result = subject.loadReadGuids()
        #expect(result == [])
    }

    @Test func saveDate() throws {
        subject.saveDate(.distantPast)
        #expect(defaults.methodsCalled == ["set(_:forKey:)"])
        let data = try #require(defaults.sets["date"] as? Data)
        let result = try PropertyListDecoder().decode(Persistence.Wrapper<Date>.self, from: data).value
        #expect(result == .distantPast)
    }

    @Test func loadDate() throws {
        let data = try PropertyListEncoder().encode(Persistence.Wrapper(value: Date.distantPast))
        defaults.gets["date"] = data
        let result = subject.loadDate()
        #expect(result == .distantPast)
    }

    @Test func loadDateFail() throws {
        let result = subject.loadDate()
        #expect(result == nil)
    }

    @Test func saveSize() throws {
        subject.saveSize(42)
        #expect(defaults.methodsCalled == ["set(_:forKey:)"])
        let data = try #require(defaults.sets["size"] as? Data)
        let result = try PropertyListDecoder().decode(Persistence.Wrapper<Int>.self, from: data).value
        #expect(result == 42)
    }

    @Test func loadSize() throws {
        let data = try PropertyListEncoder().encode(Persistence.Wrapper(value: 42))
        defaults.gets["size"] = data
        let result = subject.loadSize()
        #expect(result == 42)
    }

    @Test func loadSizeFail() throws {
        let result = subject.loadSize()
        #expect(result == nil)
    }

    /*
    func saveFeed(_: [FeedItem])
    func loadFeed() -> [FeedItem]?
    func saveReadGuids(_: Set<String>)
    func loadReadGuids() -> Set<String>
    func saveDate(_: Date)
    func loadDate() -> Date?
    func saveSize(_: Int)
    func loadSize() -> Int?
     */
}
