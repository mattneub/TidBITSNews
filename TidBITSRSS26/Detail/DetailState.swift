import Foundation

struct DetailState: Equatable {
    var fontSize: Int = 18
    var item = FeedItem(guid: "dummy")
    var pad = false
    var template: String = ""
    var templateURL: URL?

    var contentString: String {
        template
            .replacingOccurrences(of:"<maximagewidth>", with:"80%")
            .replacingOccurrences(of:"<fontsize>", with: String(self.fontSize))
            .replacingOccurrences(of:"<guid>", with: self.item.guid)
            .replacingOccurrences(of:"<author>", with: self.item.author ?? "")
            .replacingOccurrences(of: "<content>", with: self.item.content)
            .replacingOccurrences(of: "http://", with: "https://")
            .replacingOccurrences(of:"<date>", with: self.item.pubDate.ourFormat)
            .replacingOccurrences(of:"<margin>", with: pad ? "20" : "5")
    }
}
