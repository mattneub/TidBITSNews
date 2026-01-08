import UIKit

/// Reducer used to move feed item information around the app. In particular, this means that we
/// never have to cross any isolation boundaries with an FDPFeed or an FDPItem.
struct FeedItem: Equatable, Codable {
    var title: String = ""
    let guid: String
    var blurb: String?
    var author: String?
    var pubDate: Date = Date.distantPast
    var content: String = ""
    var isFirst: Bool = false
    var isLast: Bool = false
    var hasBeenRead: Bool = false
    var url: URL?
}

extension FeedItem {
    /// Initialize from an FDPItem.
    /// - Parameter item: The FDPItem, as it came from the feed parser.
    nonisolated init(fdpItem item: FDPItem) {
        self.guid = item.guid
        self.title = titleOfItem(item)
        self.blurb = blurbOfItem(item)
        self.author = authorOfItem(item)
        self.pubDate = item.pubDate
        self.content = item.content.trimmingCharacters(in: .whitespacesAndNewlines)
        self.url = URL(string: item.link.href)
    }

    nonisolated func titleOfItem(_ item: FDPItem) -> String {
        let result = item.title ?? ""
        return result.dealingWithEntities.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    nonisolated func blurbOfItem(_ item: FDPItem) -> String? {
        guard let blurbNodes = item.extensionElements(
            withXMLNamespace: "http://www.tidbits.com/dummy",
            elementName: "app_blurb"
        ) else {
            return nil
        }
        guard let blurbNode = blurbNodes.last as? FDPExtensionNode else {
            return nil
        }
        guard var blurb = blurbNode.stringValue else {
            return nil
        }
        // crucial that it be a single paragraph, so eliminate returns
        blurb.replace(/[\n\r]/, with: " ")
        // remove stray html tags
        blurb.replace(/<.*?>/, with: "")
        // munge, trim, and return
        return blurb.dealingWithEntities.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    nonisolated func authorOfItem(_ item: FDPItem) -> String? {
        guard let authorNodes = item.extensionElements(
            withXMLNamespace: "http://www.tidbits.com/dummy",
            elementName: "app_author_name"
        ) else {
            return nil
        }
        guard let authorNode = authorNodes.last as? FDPExtensionNode else {
            return nil
        }
        return authorNode.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var attributedSummary: NSAttributedString? {
        guard let proposedHeadlineFont = UIFont(name: "AvenirNextCondensed-DemiBold", size: 17) else {
            return nil // shouldn't happen
        }
        let actualHeadlineFont = UIFontMetrics(forTextStyle: .headline).scaledFont(for: proposedHeadlineFont)
        let blurbFont = UIFont.preferredFont(forTextStyle: .subheadline)

        let title = self.title + "\n"
        let content1 = AttributedString(title, attributes: AttributeContainer()
            .font(actualHeadlineFont)
            .foregroundColor(UIColor.label)
        )
        let blurb = self.blurb ?? ""
        let content2 = AttributedString(blurb, attributes: AttributeContainer()
            .font(blurbFont)
            .foregroundColor(UIColor.label)
        )
        let content = content1 + content2
        return NSAttributedString(content)
    }

    var attributedTitle: NSAttributedString? {
        guard let summary = attributedSummary else {
            return nil
        }
        let attributedString = AttributedString(summary)
        if let cutoff = attributedString.characters.firstIndex(of: "\n") {
            var titleString = attributedString[attributedString.startIndex..<cutoff]
            titleString.mergeAttributes(.init([.paragraphStyle: NSMutableParagraphStyle().applying {
                $0.firstLineHeadIndent = 4
                $0.headIndent = 4
                $0.tailIndent = -4
            }]))
            return NSAttributedString(AttributedString(titleString))
        } else {
            return nil
        }
    }
}
