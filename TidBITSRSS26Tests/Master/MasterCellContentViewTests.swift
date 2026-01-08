@testable import TidBITSRSS26
import Testing
import UIKit
import SnapshotTesting
import WaitWhile

private struct MasterCellContentViewTests {
    @Test("Setting the content view's configuration configures the view correctly")
    func contentView() throws {
        var feedItem = FeedItem(
            title: "Title",
            guid: "guid",
            blurb: "Blurb"
        )
        let subject = MasterCellContentView(
            configuration: MasterCellContentConfiguration(
                feedItem: feedItem
            )
        )
        #expect(subject.drawer.isDescendant(of: subject))
        #expect(subject.hasBeenRead.isDescendant(of: subject))
        #expect(subject.drawer.translatesAutoresizingMaskIntoConstraints == false)
        #expect(subject.drawer.numberOfLines == 0)
        #expect(subject.drawer.accessibilityLabel == "Article title")
        #expect(subject.drawer.accessibilityValue == "Title")
        #expect(subject.drawer.accessibilityHint == "Blurb")
        #expect(subject.isAccessibilityElement == false)
        #expect(subject.accessibilityElements as? [UIView] == [subject.drawer])
        #expect(subject.drawer.accessibilityTraits == .button)
        #expect(subject.hasBeenRead.image == UIImage(systemName: "circle.fill"))
        #expect(subject.hasBeenRead.tintColor == .myPurple)
        #expect(subject.hasBeenRead.constraints[0].firstAttribute == .width)
        #expect(subject.hasBeenRead.constraints[0].constant == 18)
        #expect(subject.hasBeenRead.constraints[1].firstAttribute == .height)
        #expect(subject.hasBeenRead.constraints[1].constant == 18)
        let attributedText = try #require(subject.drawer.attributedText)
        #expect(attributedText == feedItem.attributedSummary)
        #expect(subject.hasBeenRead.isHidden == false) // because feed item was false by default
        feedItem.hasBeenRead = true
        let configuration = MasterCellContentConfiguration(feedItem: feedItem)
        subject.apply(configuration: configuration)
        #expect(subject.hasBeenRead.isHidden == true)
    }

    @Test("hasBeenReadTrailingConstraint constant value depends upon trait collection split view environment")
    func constraint() async {
        let feedItem = FeedItem(
            title: "Title",
            guid: "guid",
            blurb: "Blurb"
        )
        let subject = MasterCellContentView(
            configuration: MasterCellContentConfiguration(
                feedItem: feedItem
            )
        )
        let window = makeWindow(view: subject)
        window.traitOverrides.splitViewControllerLayoutEnvironment = .collapsed
        await #while(subject.traitCollection.splitViewControllerLayoutEnvironment != .collapsed)
        #expect(subject.hasBeenReadTrailingConstraint.constant == 0)
        window.traitOverrides.splitViewControllerLayoutEnvironment = .expanded
        await #while(subject.traitCollection.splitViewControllerLayoutEnvironment != .expanded)
        #expect(subject.hasBeenReadTrailingConstraint.constant == -10)
    }

    @Test("View looks right")
    func snapshot() {
        let feedItem = FeedItem(
            title: "This is the title, tra-la-la, this is the title, tra-la-la, this is the title, tra-la-la, this is the title, tra-la-la",
            guid: "guid",
            blurb: "This is the blurb, tra-la-la, this is the blurb, tra-la-la, this is the blurb, tra-la-la, this is the title I mean the blurb, tra-la-la"
        )
        let subject = MasterCellContentView(
            configuration: MasterCellContentConfiguration(
                feedItem: feedItem
            )
        )
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        viewController.view.addSubview(subject)
        subject.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subject.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            subject.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            subject.widthAnchor.constraint(equalToConstant: 300),
        ])
        viewController.view.layoutIfNeeded()
        assertSnapshot(of: subject, as: .image)
    }
}
