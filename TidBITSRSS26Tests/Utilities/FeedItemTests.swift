@testable import TidBITSRSS26
import Testing
import UIKit

private struct FeedItemTests {
    @Test("title deals correctly with html entities, guid is copied")
    func title() {
        let item = MockFDPItem()
        item._title = "H&#233;ll&#246;"
        item._guid = "guid"
        let subject = FeedItem(fdpItem: item)
        #expect(subject.title == "Héllö")
        #expect(subject.guid == "guid")
    }

    @Test("blurb correctly extracts blurb")
    func blurb() {
        // I think the simplest way to do this is to let the feed parser parse some actual XML...
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
        let item = feed.items.first as! FDPItem
        let subject = FeedItem(fdpItem: item)
        #expect(subject.blurb == "hey nonny nonny")
        print(subject.blurb!)
    }

    @Test("attributedSummary: is correctly constructed")
    func attributedSummary() throws {
        let subject = FeedItem(title: "Title", guid: "guid", blurb: "Blurb")
        let summary = try #require(subject.attributedSummary)
        let attributedString = AttributedString(summary)
        let runs = attributedString.runs
        #expect(runs.count == 4)
        var index = runs.startIndex
        #expect(runs[index].attributes.uiKit.font?.fontName == "AvenirNextCondensed-DemiBold")
        #expect(String(attributedString.characters[runs[index].range]) == "T")
        index = runs.index(after: index)
        #expect(runs[index].attributes.uiKit.font?.fontName == "AvenirNextCondensed-DemiBold")
        #expect(String(attributedString.characters[runs[index].range]) == "itle\n")
        index = runs.index(after: index)
        #expect(runs[index].attributes.uiKit.font?.fontName == ".SFUI-Regular")
        #expect(String(attributedString.characters[runs[index].range]) == "B")
        index = runs.index(after: index)
        #expect(runs[index].attributes.uiKit.font?.fontName == ".SFUI-Regular")
        #expect(String(attributedString.characters[runs[index].range]) == "lurb")
    }
}
