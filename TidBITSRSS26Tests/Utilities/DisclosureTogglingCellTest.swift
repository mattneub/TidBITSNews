@testable import TidBITSRSS26
import Testing
import UIKit
import WaitWhile

private struct DisclosureTogglingCellTests {
    @Test("when split view trait is collapsed, cell has disclosure accessory; when not, not")
    func collapsedExpanded() async {
        let subject = DisclosureTogglingCell()
        let window = makeWindow(view: subject)
        window.traitOverrides.splitViewControllerLayoutEnvironment = .collapsed
        await #while(subject.traitCollection.splitViewControllerLayoutEnvironment != .collapsed)
        #expect(subject.accessoryType == .disclosureIndicator)
        window.traitOverrides.splitViewControllerLayoutEnvironment = .expanded
        await #while(subject.traitCollection.splitViewControllerLayoutEnvironment != .expanded)
        #expect(subject.accessoryType == .none)
    }
}
