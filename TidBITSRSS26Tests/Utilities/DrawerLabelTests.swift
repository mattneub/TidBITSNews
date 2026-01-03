@testable import TidBITSRSS26
import Testing
import SnapshotTesting
import UIKit

private struct DrawerLabelTests {
    let subject = DrawerLabel()

    @Test("label looks correct")
    func looksCorrect() {
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        viewController.view.addSubview(subject)
        subject.text = "This is a test. This is a test. This is very much a test."
        subject.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subject.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            subject.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            subject.widthAnchor.constraint(equalToConstant: 200),
        ])
        viewController.view.layoutIfNeeded()
        assertSnapshot(of: subject, as: .image)
    }

    @Test("label looks correct with line wrapping")
    func looksCorrectWrapping() {
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        viewController.view.addSubview(subject)
        subject.text = "This is a test. This is a test. This is very much a test."
        subject.numberOfLines = 0
        subject.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subject.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            subject.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            subject.widthAnchor.constraint(equalToConstant: 200),
        ])
        viewController.view.layoutIfNeeded()
        assertSnapshot(of: subject, as: .image)
    }
}
