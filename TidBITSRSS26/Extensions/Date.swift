import Foundation

extension Date {
    var ourFormat: String {
        let format = Date.VerbatimFormatStyle(
            format: "\(day: .defaultDigits) \(month: .wide) \(year: .defaultDigits)",
            locale: Locale(identifier: "en_US"),
            timeZone: .autoupdatingCurrent,
            calendar: .init(identifier:.gregorian)
        )
        return self.formatted(format)
    }
    var ourFormatWithTime: String {
        let format = Date.VerbatimFormatStyle(
            format: """
            \(day: .defaultDigits) \(month: .wide) \(year: .defaultDigits) at \
            \(hour: .defaultDigits(clock: .twelveHour, hourCycle: .oneBased)):\(minute: .twoDigits) \
            \(dayPeriod: .standard(.abbreviated)) \(timeZone: .specificName(.short))
            """,
            locale: Locale(identifier: "en_US"),
            timeZone: .autoupdatingCurrent,
            calendar: .init(identifier:.gregorian)
        )
        return self.formatted(format)
    }
}
