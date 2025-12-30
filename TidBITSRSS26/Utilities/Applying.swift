import UIKit

// Shamelessly stolen from https://github.com/devxoul/Then with names changed
protocol Applicand {}
extension Applicand where Self: AnyObject {
    /// "Lend" a reference object to a closure so that it can be modified conveniently.
    /// Particularly useful when we create an object and then modify it, especially in a property
    /// declaration.
    func applying(_ closure: (Self) throws -> Void) rethrows -> Self {
        try closure(self)
        return self
    }
}
extension NSObject: Applicand {}

