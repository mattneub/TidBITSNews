@testable import TidBITSRSS26
import Testing

private struct MutableCollectionTests {
    @Test("modifyEach works")
    func modifyEach() {
        struct Person: Equatable { var name: String }
        var collection = [Person(name: "harpo"), Person(name: "groucho")]
        collection.modifyEach {
            $0.name = $0.name.uppercased()
        }
        #expect(collection == [Person(name: "HARPO"), Person(name: "GROUCHO")])
    }
}
