@testable import TidBITSRSS26
import Testing
import Foundation

private struct DateTests {
    @Test("ourFormat formats the date as expected")
    func ourFormat() {
        let dateComponents = DateComponents(calendar: .init(identifier: .gregorian), year: 1954, month: 8, day: 10)
        let date = dateComponents.date!
        let result = date.ourFormat
        #expect(result == "10 August 1954")
    }

    @Test("ourFormatWithTime formats the date and time as expected")
    func ourFormatWithTime() {
        let cal = Calendar(identifier: .gregorian)
        let tz = TimeZone.autoupdatingCurrent
        let dateComponents = DateComponents(calendar: cal, timeZone: tz, year: 1954, month: 8, day: 10, hour: 4, minute: 0, second: 0)
        let date = dateComponents.date!
        let result = date.ourFormatWithTime
        #expect(result == "10 August 1954 at 4:00 AM GMT-7")
        // but in the app I see PST as expected, why this difference?
    }
}
