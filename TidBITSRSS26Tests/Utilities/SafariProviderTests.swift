@testable import TidBITSRSS26
import Testing
import UIKit
import SafariServices

private struct SafariProviderTests {
    @Test("safari provider provides a safari view controller")
    func provides() {
        let subject = SafariProvider()
        let result = subject.provide(for: URL(string: "https://www.example.com")!)
        #expect(result is SFSafariViewController)
    }
}
