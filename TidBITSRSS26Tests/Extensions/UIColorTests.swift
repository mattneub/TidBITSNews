@testable import TidBITSRSS26
import Testing
import UIKit

private struct UIColorTests {
    @Test("myPurple is correct")
    func myPurple() {
        #expect(UIColor.myPurple == UIColor(red: 0.627, green: 0.533, blue: 0.694, alpha: 1))
    }
}
