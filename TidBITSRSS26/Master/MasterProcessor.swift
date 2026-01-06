final class MasterProcessor: Processor {
    weak var coordinator: (any RootCoordinatorType)?

    weak var presenter: (any ReceiverPresenter<MasterEffect, MasterState>)?

    lazy var cycler: Cycler = Cycler(processor: self)

    var state = MasterState()

    func receive(_ action: MasterAction) async {
        switch action {
        case .appearing:
            await presenter?.receive(.reloadTable)
        case .fetchFeed(let force):
            do {
                try await fetchFeed(forceNetwork: force)
            } catch {
                print(error) // TODO: show user an alert?
            }
            // whether we succeeded or not, must now present to settle interface
            await presenter?.present(state)
        case .selected(let row):
            state.selectedItemIndex = row
            var item = state.parsedData[row]
            item.isFirst = row == 0
            item.isLast = row == state.parsedData.count - 1
            coordinator?.showDetail(item: item)
            state.guidsOfReadItems.insert(item.guid)
            state.parsedData[row].hasBeenRead = true
        case .updateHasBeenRead(let hasBeenRead, let row):
            state.parsedData[row].hasBeenRead = hasBeenRead
            let guid = state.parsedData[row].guid
            if hasBeenRead {
                state.guidsOfReadItems.insert(guid)
            } else {
                state.guidsOfReadItems.remove(guid)
            }
        case .viewDidAppear:
            // TODO: get fetch date from persistence
            if state.parsedData.isEmpty {
                await cycler.receive(.fetchFeed(forceNetwork: false))
            }
        }
    }
    
    /// Fetch feed data from the feed fetcher and configure the state and persistence.
    /// - Parameter forceNetwork: Whether to require fetching from the network even if we
    /// have a stored feed already.
    func fetchFeed(forceNetwork: Bool = false) async throws {
        let result = try await services.feedFetcher.fetchFeed(forceNetwork)
        state.parsedData = result?.items ?? []
        let guidsOfReadItems = state.guidsOfReadItems // copy so no simultaneous access
        state.parsedData.modifyEach {
            $0.hasBeenRead = guidsOfReadItems.contains($0.guid)
        }
        if result?.type == .network {
            state.lastNetworkFetchDate = Date.now
            // TODO: save fetch date to persistence
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
