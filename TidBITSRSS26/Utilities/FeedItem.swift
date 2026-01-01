import UIKit

/// Reducer used to move feed item information around the app.
struct FeedItem: Equatable {
    var title: String = ""
    let guid: String
    var blurb: String?
}

extension FeedItem {
    /// Initialize from an FDPItem.
    /// - Parameter item: The FDPItem, as it came from the feed parser.
    init(fdpItem item: FDPItem) {
        self.guid = item.guid
        self.title = titleOfItem(item)
        self.blurb = blurbOfItem(item)
    }

    /// Munge the FDPItem's title to convert entities, of the form "&#123", to Unicode characters.
    /// - Parameter item: The FDPItem.
    /// - Returns: The munged title.
    func titleOfItem(_ item: FDPItem) -> String {
        var result = item.title ?? ""
        // what follows works, but it's slow...
        /*
         guard let d = ("<!DOCTYPE html><html><meta charset=\"utf-8\" /><body>\(s)</body></html>").data(using: .utf8)
         else { return "" }
         do {
         let att = try NSAttributedString(data: d, options: [.documentType:NSAttributedString.DocumentType.html], documentAttributes: nil)
         return att.string
         } catch {
         return ""
         }
         */
        // so if possible I'd like to catch rare entities manually
        // that is what the string extension from github lets us do
        // so I could just call that extension

        // however, in real life we seem to get just one sort of case,
        // which I can find and convert with a single regular expression
        // three or four digit decimal encoding
        let pattern = "&#(\\d\\d\\d\\d?);"
        guard let expression = try? NSRegularExpression(pattern: pattern, options: []) else {
            return result
        }
        let range = result.startIndex..<result.endIndex
        let matches = expression.matches(in: result, options: [], range: NSRange(range, in: result))
        for match in matches.reversed() {
            let nsString = result as NSString
            let number = nsString.substring(with: match.range(at: 1))
            if let code = Int(number), let scalar = UnicodeScalar(code) {
                result = nsString.replacingCharacters(in: match.range, with: String(scalar)) as String
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
        blurb = blurb.replacingOccurrences(of: "\n", with: " ")
        blurb = blurb.replacingOccurrences(of: "\r", with: " ")
        // remove stray html tags and extra whitespace
        guard let tag = try? NSRegularExpression(pattern: "<.*?>", options: []) else {
            return nil // shouldn't happen
        }
        blurb = tag.stringByReplacingMatches(
            in: blurb,
            options: [],
            range: NSMakeRange(0, blurb.utf16.count),
            withTemplate: ""
        ).trimmingCharacters(in: .whitespacesAndNewlines)
        return blurb
    }

    var attributedSummary: NSAttributedString? {
        guard let proposedHeadlineFont = UIFont(name: "AvenirNextCondensed-DemiBold", size: 17) else {
            return nil // shouldn't happen
        }
        let actualHeadlineFont = UIFontMetrics(forTextStyle: .headline).scaledFont(for: proposedHeadlineFont)
        let blurbFont = UIFont.preferredFont(forTextStyle: .subheadline)

        let title = self.title + "\n"
        let content = NSMutableAttributedString(string: title, attributes: [
            .font: actualHeadlineFont,
            .foregroundColor: UIColor.black,
            .kern: NSNull()
        ])
        var blurb = self.blurb ?? ""
        let content2 = NSMutableAttributedString(string: blurb, attributes: [
            .font: blurbFont,
            .foregroundColor: UIColor.black,
            .kern: NSNull()
        ])
        content.append(content2)

        // use paragraph styles to dictate our own margins
        content.addAttribute(
            .paragraphStyle,
            value: NSMutableParagraphStyle().applying {
                $0.lineBreakMode = .byWordWrapping
            },
            range: NSMakeRange(0, 1))
        content.addAttribute(
            .paragraphStyle,
            value: NSMutableParagraphStyle().applying {
                $0.lineBreakMode = .byWordWrapping
            },
            range: NSMakeRange(title.utf16.count, 1))

        return content
    }

}
