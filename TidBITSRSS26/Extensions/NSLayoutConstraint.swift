import UIKit

/// I'm not a fan of shortcut constraint DSLs like SnapKit.
/// The one thing I most can't stand about constraint code, though, is that you have to say
/// `isActive = true` and you can't set the priority in the same line of code. This extension
/// is just enough to fix that. We return the constraint itself in case we need to do something
/// else with it.
extension NSLayoutConstraint {
    @discardableResult
    func activate(priority priorityValue: Float = 1000) -> NSLayoutConstraint {
        self.priority = .init(priorityValue)
        self.isActive = true
        return self
    }
}
