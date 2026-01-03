@testable import TidBITSRSS26
import Testing
import UIKit

private struct UIColorTests {
    @Test("myPurple is correct")
    func myPurple() {
        #expect(UIColor.myPurple == UIColor(red: 0.627, green: 0.533, blue: 0.694, alpha: 1))
    }

    @Test("color combinations work as expected")
    func combinations() {
        let result = UIColor.red * 0.5 + UIColor.white * 0.5
        #expect(result == UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 1))
    }
}
