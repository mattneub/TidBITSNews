import Foundation

final class DetailProcessor: Processor {
    weak var coordinator: (any RootCoordinatorType)?
    
    weak var presenter: (any ReceiverPresenter<Void, DetailState>)?
    
    var state = DetailState()
    
    func receive(_ action: DetailAction) async {
        switch action {
        case .newState(let newState):
            state = newState
            loadHTML()
            await presenter?.present(state)
        }
    }

    func loadHTML() {
        guard let templateURL = services.bundle.url(forResource: "htmltemplate", withExtension: "txt") else {
            return // shouldn't happen
        }
        guard var contentString = try? String(contentsOf: templateURL, encoding: .utf8) else {
            return // shouldn't happen
        }
        contentString = contentString
            .replacingOccurrences(of:"<maximagewidth>", with:"80%")
            .replacingOccurrences(of:"<fontsize>", with: "18" /* String(self.fontsize) */)
            .replacingOccurrences(of:"<guid>", with: state.item.guid)
            .replacingOccurrences(of:"<author>", with: state.item.author ?? "")
            .replacingOccurrences(of: "<content>", with: state.item.content)
            .replacingOccurrences(of: "http://", with: "https://")
            .replacingOccurrences(of:"<date>", with: { () -> String in
                let format = Date.VerbatimFormatStyle(
                    format: "\(day: .defaultDigits) \(month: .wide) \(year: .defaultDigits)",
                    locale: Locale(identifier: "en_US"),
                    timeZone: .autoupdatingCurrent,
                    calendar: .init(identifier:.gregorian)
                )
                return state.item.pubDate.formatted(format)
            }())
        state.contentString = contentString
        state.templateURL = templateURL
    }
}
