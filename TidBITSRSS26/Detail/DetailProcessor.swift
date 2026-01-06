import Foundation

final class DetailProcessor: Processor {
    weak var coordinator: (any RootCoordinatorType)?
    
    weak var presenter: (any ReceiverPresenter<DetailEffect, DetailState>)?

    weak var delegate: (any DetailProcessorDelegate)?

    var state = DetailState()
    
    func receive(_ action: DetailAction) async {
        switch action {
        case .changeFontSize:
            var newFontSize = state.fontSize + 2
            if newFontSize >= 26 {
                newFontSize = 12
            }
            state.fontSize = newFontSize // TODO: and save into persistence
            let jsToInject = "document.body.style.fontSize='\(newFontSize)px';'';"
            await presenter?.receive(.newFontSize(jsToInject))
        case .goNext:
            await delegate?.goNext()
        case .goPrev:
            await delegate?.goPrev()
        case .newItem(let newItem):
            state.item = newItem
            loadHTML()
            await presenter?.present(state)
        }
    }

    func loadHTML() {
        guard let templateURL = services.bundle.url(forResource: "htmltemplate", withExtension: "txt") else {
            return // shouldn't happen
        }
        guard let template = try? String(contentsOf: templateURL, encoding: .utf8) else {
            return // shouldn't happen
        }
        state.template = template
        state.templateURL = templateURL
    }
}

protocol DetailProcessorDelegate: AnyObject {
    func goNext() async
    func goPrev() async
}
