import UIKit

/// Reducer used to move feed item information around the app.
struct FeedItem: Equatable {
    var title: String = ""
    let guid: String
    var blurb: String?
    var author: String?
    var pubDate: Date = Date.distantPast
    var content: String = ""
}

extension FeedItem {
    /// Initialize from an FDPItem.
    /// - Parameter item: The FDPItem, as it came from the feed parser.
    init(fdpItem item: FDPItem) {
        self.guid = item.guid
        self.title = titleOfItem(item)
        self.blurb = blurbOfItem(item)
        self.author = authorOfItem(item)
        self.pubDate = item.pubDate
        self.content = item.content
    }

    /// Munge the FDPItem's title to convert entities, of the form "&#123", to Unicode characters.
    /// - Parameter item: The FDPItem.
    /// - Returns: The munged title.
    func titleOfItem(_ item: FDPItem) -> String {
        var result = item.title ?? ""
        // deal with entities; in real life we seem to get just one sort of case,
        // which I can find and convert with a single regular expression
        // that catches three or four digit decimal encoding
        for match in result.matches(of: /&#(\d\d\d\d?);/).reversed() {
            if let code = Int(match.output.1), let scalar = UnicodeScalar(code) {
                result.replaceSubrange(match.range, with: String(scalar))
            }
        }
        return result
    }

    func blurbOfItem(_ item: FDPItem) -> String? {
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
        // trim and return
        return blurb.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func authorOfItem(_ item: FDPItem) -> String? {
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
            .foregroundColor(.black)
        )
        let blurb = self.blurb ?? ""
        let content2 = AttributedString(blurb, attributes: AttributeContainer()
            .font(blurbFont)
            .foregroundColor(.black)
        )
        let content = content1 + content2
        // we don't need this any longer but here's how to do it just in case
//        content.mergeAttributes(.init([.paragraphStyle: NSMutableParagraphStyle().applying {
//            $0.lineBreakMode = .byWordWrapping
//        }]))
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
