import UIKit

struct MasterState: Equatable {
    var guidsOfReadItems = Set<String>()
    var lastNetworkFetchDate: Date?
    var parsedData = [FeedItem]()
    var selectedItemIndex = -1

    var lastNetworkFetchDateString: String? {
        guard let lastNetworkFetchDate else {
            return nil
        }
        return "Updated \(lastNetworkFetchDate.ourFormatWithTime)"
    }

    var lastNetworkFetchDateStringAttributed: AttributedString? {
        guard let lastNetworkFetchDateString else {
            return nil
        }
        return AttributedString(lastNetworkFetchDateString, attributes: AttributeContainer
            .foregroundColor(UIColor.white)
            .font(UIFont(name: "Helvetica-Bold", size: 14) ?? UIFont.systemFont(ofSize: 14))
        )
    }
}
