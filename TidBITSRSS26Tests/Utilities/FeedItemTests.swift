@testable import TidBITSRSS26
import Testing
import UIKit

private struct FeedItemTests {
    @Test("guid, pubDate, content, url are copied directly")
    func guidPubDateContentUrl() {
        let item = MockFDPItem()
        item._guid = "guid"
        item._pubDate = Date.distantPast
        item._content = "content"
        let link = MockFDPLink()
        link._href = "http://www.example.com"
        item._link = link
        let subject = FeedItem(fdpItem: item)
        #expect(subject.guid == "guid")
        #expect(subject.pubDate == Date.distantPast)
        #expect(subject.content == "content")
        #expect(subject.url == URL(string: "http://www.example.com"))
    }

    @Test("title deals correctly with html entities")
    func title() {
        let item = MockFDPItem()
        item._title = "H&#233;ll&#246;"
        let subject = FeedItem(fdpItem: item)
        #expect(subject.title == "Héllö")
    }

    @Test("blurb correctly extracts blurb, author correctly extracts author")
    func blurbAndAuthor() {
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
        #expect(subject.author == "Adam Engst")
    }

    @Test("attributedSummary: is correctly constructed")
    func attributedSummary() throws {
        let subject = FeedItem(title: "Title", guid: "guid", blurb: "Blurb")
        let summary = try #require(subject.attributedSummary)
        let attributedString = AttributedString(summary)
        let runs = attributedString.runs
        #expect(runs.count == 2)
        var index = runs.startIndex
        #expect(runs[index].attributes.uiKit.font?.fontName == "AvenirNextCondensed-DemiBold")
        #expect(runs[index].attributes.uiKit.foregroundColor == .label)
        #expect(String(attributedString.characters[runs[index].range]) == "Title\n")
        index = runs.index(after: index)
        #expect(runs[index].attributes.uiKit.font?.fontName == ".SFUI-Regular")
        #expect(String(attributedString.characters[runs[index].range]) == "Blurb")
        #expect(runs[index].attributes.uiKit.foregroundColor == .label)
    }

    @Test("attributedTitle: is correctly constructed")
    func attributedTitle() throws {
        let subject = FeedItem(title: "Title", guid: "guid", blurb: "Blurb")
        let title = try #require(subject.attributedTitle)
        let attributedString = AttributedString(title)
        let runs = attributedString.runs
        #expect(runs.count == 1)
        let index = runs.startIndex
        #expect(runs[index].attributes.uiKit.font?.fontName == "AvenirNextCondensed-DemiBold")
        #expect(runs[index].attributes.uiKit.foregroundColor == .label)
        let style = try #require(runs[index].attributes.uiKit.paragraphStyle)
        #expect(style.firstLineHeadIndent == 4)
        #expect(style.headIndent == 4)
        #expect(style.tailIndent == -4)
    }
}

extension NSParagraphStyle: @retroactive @unchecked Sendable {}
