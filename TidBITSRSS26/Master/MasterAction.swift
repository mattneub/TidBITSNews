enum MasterAction: Equatable {
    case selected(Int)
    case updateHasBeenRead(Bool, for: Int)
    case viewDidAppear
}
