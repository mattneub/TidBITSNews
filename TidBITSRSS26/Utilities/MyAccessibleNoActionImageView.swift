import UIKit

class MyAccessibleNoActionImageView : UIImageView {
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return .header
        } set {}
    }
    override func accessibilityActivate() -> Bool {
        return true // heh heh, this means "I did all that is needed, do not do your default action"
    }
}
