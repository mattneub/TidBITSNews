@testable import TidBITSRSS26
import Testing
import UIKit

private struct NSLayoutConstraintTests {
    @Test("activate() activates with the given priority")
    func activate() {
        let view = UIView()
        view.widthAnchor.constraint(equalToConstant: 100).activate()
        #expect(view.constraints[0].firstAttribute == .width)
        #expect(view.constraints[0].constant == 100)
        #expect(view.constraints[0].isActive)
        #expect(view.constraints[0].priority.rawValue == 1000)
        view.heightAnchor.constraint(equalToConstant: 200).activate(priority: .init(999))
        #expect(view.constraints[1].firstAttribute == .height)
        #expect(view.constraints[1].constant == 200)
        #expect(view.constraints[1].isActive)
        #expect(view.constraints[1].priority.rawValue == 999)
    }
}
