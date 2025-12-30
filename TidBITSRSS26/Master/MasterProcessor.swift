final class MasterProcessor: Processor {
    weak var coordinator: (any RootCoordinatorType)?

    weak var presenter: (any ReceiverPresenter<Void, MasterState>)?

    var state = MasterState()

    func receive(_ action: MasterAction) async {}
}
