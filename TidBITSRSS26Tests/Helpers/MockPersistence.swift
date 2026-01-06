@testable import TidBITSRSS26
import Foundation

final class MockPersistence: PersistenceType {
    nonisolated(unsafe) var methodsCalled = [String]()
    nonisolated(unsafe) var feed: [FeedItem]?
    nonisolated(unsafe) var guids: Set<String> = []
    nonisolated(unsafe) var date: Date?
    nonisolated(unsafe) var size: Int?

    func saveFeed(_ feed: [FeedItem]) {
        methodsCalled.append(#function)
        self.feed = feed
    }

    func loadFeed() -> [FeedItem]? {
        methodsCalled.append(#function)
        return feed
    }

    func saveReadGuids(_ guids: Set<String>) {
        methodsCalled.append(#function)
        self.guids = guids
    }

    func loadReadGuids() -> Set<String> {
        methodsCalled.append(#function)
        return guids
    }

    func saveDate(_ date: Date) {
        methodsCalled.append(#function)
        self.date = date
    }

    func loadDate() -> Date? {
        methodsCalled.append(#function)
        return date
    }

    func saveSize(_ size: Int) {
        methodsCalled.append(#function)
        self.size = size
    }

    func loadSize() -> Int? {
        methodsCalled.append(#function)
        return size
    }

}
