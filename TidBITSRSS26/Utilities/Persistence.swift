/// We are deliberately unconcerned with what the app did in the past. All previous saved
/// defaults are ignored; we are encoding/decoding in a completely different way, and we are
/// encoding/decoding a different group of things. The user will lose their defaults on upgrade,
/// and that's no biggie.
struct Defaults {
    static let feed = "feeditems"
    static let read = "readitems"
    static let date = "date"
    static let size = "size"
}

protocol PersistenceType: Sendable {
    func saveFeed(_: [FeedItem])
    func loadFeed() -> [FeedItem]?
    func saveReadGuids(_: Set<String>)
    func loadReadGuids() -> Set<String>
    func saveDate(_: Date)
    func loadDate() -> Date?
    func saveSize(_: Int)
    func loadSize() -> Int?
}

final class Persistence: PersistenceType {
    func saveFeed(_ items: [FeedItem]) {
        save(items, key: Defaults.feed)
    }

    func loadFeed() -> [FeedItem]? {
        return load(key: Defaults.feed)
    }

    func saveReadGuids(_ guids: Set<String>) {
        save(guids, key: Defaults.read)
    }

    func loadReadGuids() -> Set<String> {
        if let guids: Set<String> = load(key: Defaults.read) {
            return guids
        }
        return []
    }

    func saveDate(_ date: Date) {
        save(date, key: Defaults.date)
    }

    func loadDate() -> Date? {
        return load(key: Defaults.date)
    }

    func saveSize(_ size: Int) {
        save(size, key: Defaults.size)
    }

    func loadSize() -> Int? {
        return load(key: Defaults.size)
    }

    func save<T: Codable>(_ what: T, key: String) {
        if let data = try? PropertyListEncoder().encode(Wrapper(value: what)) {
            services.userDefaults.set(data, forKey: key)
        }
    }

    func load<T: Codable>(key: String) -> T? {
        if let data = services.userDefaults.data(forKey: key) {
            if let result = try? PropertyListDecoder().decode(Wrapper<T>.self, from: data) {
                return result.value
            }
        }
        return nil
    }

    struct Wrapper<T: Codable>: Codable {
        let value: T
    }
}
