final class DetailProcessor: Processor {
    weak var coordinator: (any RootCoordinatorType)?
    
    weak var presenter: (any ReceiverPresenter<Void, DetailState>)?
    
    var state = DetailState()
    
    func receive(_ action: DetailAction) async {
        switch action {
        case .initialData:
            await presenter?.present(state)
        }
    }
}
