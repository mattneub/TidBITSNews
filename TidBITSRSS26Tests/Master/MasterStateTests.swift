@testable import TidBITSRSS26
import Testing
import UIKit

private struct MasterStateTests {
    @Test("lastNetworkFetchDateString: is Updated plus formatted date")
    func lastParseString() {
        let cal = Calendar(identifier: .gregorian)
        let tz = TimeZone.autoupdatingCurrent
        let dateComponents = DateComponents(calendar: cal, timeZone: tz, year: 1954, month: 8, day: 10, hour: 4, minute: 0, second: 0)
        let date = dateComponents.date!
        var subject = MasterState()
        subject.lastNetworkFetchDate = date
        let result = subject.lastNetworkFetchDateString
        #expect(result == "Updated " + date.ourFormatWithTime)
    }

    @Test("lastNetworkFetchDateStringAttributed: is lastNetworkFetchDateString: with color and font")
    func lastParseStringAttributed() throws {
        let cal = Calendar(identifier: .gregorian)
        let tz = TimeZone.autoupdatingCurrent
        let dateComponents = DateComponents(calendar: cal, timeZone: tz, year: 1954, month: 8, day: 10, hour: 4, minute: 0, second: 0)
        let date = dateComponents.date!
        var subject = MasterState()
        subject.lastNetworkFetchDate = date
        let result = try #require(subject.lastNetworkFetchDateStringAttributed)
        let runs = result.runs
        #expect(runs.count == 1)
        #expect(String(result.characters) == subject.lastNetworkFetchDateString)
        let attributes = runs[result.runs.startIndex].attributes
        #expect(attributes.uiKit.foregroundColor == UIColor.white)
        #expect(attributes.uiKit.font == UIFont(name: "Helvetica-Bold", size: 14))
    }
}
