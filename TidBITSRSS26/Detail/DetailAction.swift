enum DetailAction: Equatable {
    case changeFontSize
    case doURL(URL)
    case goNext
    case goPrev
    case newItem(FeedItem)
    case tapTitle
}
