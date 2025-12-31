@testable import TidBITSRSS26
import Testing
import UIKit

@MainActor
private struct SceneDelegateTests {
    @Test("bootstrap: registers defaults, tells the root coordinator to create the interface")
    func bootstrap() async throws {
        let scene = try #require(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let subject = SceneDelegate()
        let mockRootCoordinator = MockRootCoordinator()
        subject.coordinator = mockRootCoordinator
        subject.bootstrap(scene: scene)
        let window = try #require(subject.window)
        #expect(window.isKeyWindow)
        #expect(window.backgroundColor == .systemBackground)
        #expect(mockRootCoordinator.methodsCalled == ["createInterface(window:)"])
        #expect(mockRootCoordinator.window === window)
    }
}

