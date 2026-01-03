final class MasterProcessor: Processor {
    weak var coordinator: (any RootCoordinatorType)?

    weak var presenter: (any ReceiverPresenter<Void, MasterState>)?

    var state = MasterState()

    func receive(_ action: MasterAction) async {
        switch action {
        case .selected(let row):
            coordinator?.showDetail(state: DetailState(item: state.parsedData[row]))
        case .viewDidAppear:
            do {
                if state.parsedData.isEmpty {
                    state.parsedData = try await services.feedFetcher.fetchFeed()
                    await presenter?.present(state)
                }
            } catch {
                // TODO: Do something useful here
                print("do something useful with this error")
            }
        }
    }
}
