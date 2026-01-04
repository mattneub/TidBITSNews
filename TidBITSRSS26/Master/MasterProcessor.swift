final class MasterProcessor: Processor {
    weak var coordinator: (any RootCoordinatorType)?

    weak var presenter: (any ReceiverPresenter<MasterEffect, MasterState>)?

    lazy var cycler: Cycler = Cycler(processor: self)

    var state = MasterState()

    func receive(_ action: MasterAction) async {
        switch action {
        case .selected(let row):
            state.selectedItemIndex = row
            var item = state.parsedData[row]
            item.isFirst = row == 0
            item.isLast = row == state.parsedData.count - 1
            coordinator?.showDetail(item: item)
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

extension MasterProcessor: DetailProcessorDelegate {
    func goNext() async {
        guard state.selectedItemIndex != -1 else {
            return // no selection
        }
        if state.selectedItemIndex < state.parsedData.count - 1 {
            let newIndex = state.selectedItemIndex + 1
            await cycler.receive(.selected(newIndex))
            await presenter?.receive(.select(newIndex))
        }
    }
    func goPrev() async {
        guard state.selectedItemIndex != -1 else {
            return // no selection
        }
        if state.selectedItemIndex > 0 {
            let newIndex = state.selectedItemIndex - 1
            await cycler.receive(.selected(newIndex))
            await presenter?.receive(.select(newIndex))
        }
    }
}
