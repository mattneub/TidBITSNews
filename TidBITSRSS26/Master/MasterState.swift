struct MasterState: Equatable {
    var guidsOfReadItems = Set<String>()
    var parsedData = [FeedItem]()
    var selectedItemIndex = -1
}
