@testable import TidBITSRSS26
import Testing

private struct FDPFeedTests {
    @Test("toFeedItems: converts to feed items")
    func toFeedItems() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0"
        xmlns:tidbits="http://www.tidbits.com/dummy"
        xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
        xmlns:media="http://search.yahoo.com/mrss/">
        <channel>
        <title>TidBITS</title>
        <link>https://tidbits.com/</link>
        <description>The description.</description>
        <lastBuildDate>Sat, 11 Mar 2023 15:54:54 -0500</lastBuildDate>
        <language>en-US</language>
        <copyright>Creative Commons License</copyright>
        <item>
            <title>
                <![CDATA[Title]]>
            </title>
            <link>https://tidbits.com/2023/03/10/linky/</link>
            <pubDate>Fri, 10 Mar 2023 23:21:32 +0000</pubDate>
            <guid isPermaLink="false">https://tidbits.com/?p=61880</guid>
            <tidbits:app_author_name>
                <![CDATA[Adam Engst]]>
            </tidbits:app_author_name>
            <tidbits:app_blurb>
                <![CDATA[hey nonny\n<i>nonny</i>]]>
            </tidbits:app_blurb>
            <description>
                <![CDATA[<p>Body.</p>]]>
            </description>
        </item>
        </channel>
        </rss>
        """
        let xmlData = xml.data(using: .utf8)
        let feed = try! FDPParser.parsedFeed(with: xmlData)
        let result = feed.toFeedItems
        let cal = Calendar(identifier: .gregorian)
        let tz = TimeZone(secondsFromGMT: 0)
        let dateComponents = DateComponents(calendar: cal, timeZone: tz, year: 2023, month: 3, day: 10, hour: 23, minute: 21, second: 32)
        let date = dateComponents.date!
        #expect(result.count == 1)
        #expect(result[0] == FeedItem(
            title: "Title",
            guid: "https://tidbits.com/?p=61880",
            blurb: "hey nonny nonny",
            author: "Adam Engst",
            pubDate: date,
            content: "<p>Body.</p>",
            isFirst: false,
            isLast: false,
            hasBeenRead: false,
            url: URL(string: "https://tidbits.com/2023/03/10/linky/")
        ))
    }
}
