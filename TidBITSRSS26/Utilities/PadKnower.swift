import UIKit

protocol PadKnowerType {
    func isPad() -> Bool
}

final class PadKnower: PadKnowerType {
    func isPad() -> Bool {
        if let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first {
            return scene.traitCollection.userInterfaceIdiom == .pad
        }
        return false // but shouldn't happen
    }
}
