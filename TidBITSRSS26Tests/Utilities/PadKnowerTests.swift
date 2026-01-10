@testable import TidBITSRSS26
import Testing
import UIKit
import WaitWhile

private struct PadKnowerTests {
    @Test("isPad true when idiom is pad")
    func isPadTrue() async throws {
        let subject = PadKnower()
        let scene = try #require(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        scene.traitOverrides.userInterfaceIdiom = .pad
        #expect(subject.isPad() == true)
    }

    @Test("isPad false when idiom is phone")
    func isPadFalse() async throws {
        let subject = PadKnower()
        let scene = try #require(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        scene.traitOverrides.userInterfaceIdiom = .phone
        #expect(subject.isPad() == false)
    }
}
