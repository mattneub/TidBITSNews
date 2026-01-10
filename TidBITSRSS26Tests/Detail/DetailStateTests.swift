@testable import TidBITSRSS26
import Testing

private struct DetailStateTests {
    @Test("contentString: performs substitutions on template")
    func contentString() {
        var subject = DetailState()
        let dateComponents = DateComponents(calendar: .init(identifier: .gregorian), year: 1954, month: 8, day: 10)
        let date = dateComponents.date!
        subject.item = FeedItem(
            title: "Title",
            guid: "guid",
            blurb: "blurb",
            author: "Author",
            pubDate: date,
            content: "Content"
        )
        subject.pad = true
        subject.template = """
        <maximagewidth> is 80%
        <fontsize> is 18
        <guid> is guid
        <author> is Author
        <content> is Content
        http:// is https://
        <date> is 10 August 1954
        <margin> is 20
        """
        #expect(subject.contentString == """
        80% is 80%
        18 is 18
        guid is guid
        Author is Author
        Content is Content
        https:// is https://
        10 August 1954 is 10 August 1954
        20 is 20
        """)
        // and when pad is false?
        subject.pad = false
        subject.template = """
        <maximagewidth> is 80%
        <fontsize> is 18
        <guid> is guid
        <author> is Author
        <content> is Content
        http:// is https://
        <date> is 10 August 1954
        <margin> is 5
        """
        #expect(subject.contentString == """
        80% is 80%
        18 is 18
        guid is guid
        Author is Author
        Content is Content
        https:// is https://
        10 August 1954 is 10 August 1954
        5 is 5
        """)
    }
}
