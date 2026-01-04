@testable import TidBITSRSS26
import Testing
import UIKit
import SnapshotTesting

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
        #expect(subject.hasBeenRead.image == UIImage(systemName: "circle.fill"))
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
