@testable import TidBITSRSS26
import Testing
import UIKit

private struct MyAccessibleNoActionImageViewTests {
    @Test("image view has correct accessibility")
    func imageView() {
        let subject = MyAccessibleNoActionImageView()
        #expect(subject.accessibilityTraits == [.header])
        #expect(subject.accessibilityActivate() == true)
    }
}
