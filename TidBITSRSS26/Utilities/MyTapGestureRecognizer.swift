
import UIKit

/// Subclass of tap gesture recognizer that gives us access to the target and action, for testing.
final class MyTapGestureRecognizer: UITapGestureRecognizer {
    weak var target: AnyObject?
    var action: Selector?
    override init(target: Any?, action: Selector?) {
        self.target = target as? AnyObject
        self.action = action
        super.init(target: target, action: action)
    }
}
