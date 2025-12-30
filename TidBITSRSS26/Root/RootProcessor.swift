final class RootProcessor: Processor {
    weak var coordinator: (any RootCoordinatorType)?

    weak var presenter: (any ReceiverPresenter<Void, RootState>)?

    var state = RootState()

    func receive(_ action: RootAction) async {}
}
