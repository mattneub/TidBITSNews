enum MasterAction: Equatable {
    case appearing
    case fetchFeed(forceNetwork: Bool)
    case selected(Int)
    case updateHasBeenRead(Bool, for: Int)
    case viewDidAppear
}
