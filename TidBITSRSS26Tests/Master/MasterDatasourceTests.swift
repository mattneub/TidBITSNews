@testable import TidBITSRSS26
import Testing
import UIKit
import WaitWhile

private struct MasterDatasourceTests {
    let subject: MasterDatasource!
    let processor = MockReceiver<MasterAction>()
    let tableView = UITableView()

    init() {
        subject = MasterDatasource(tableView: tableView, processor: processor)
    }

    @Test("Initialization: creates and configures the data source, configures the table view")
    func initialize() throws {
        let datasource = try #require(subject.datasource)
        #expect(tableView.dataSource === datasource)
        #expect(tableView.delegate === subject)
        #expect(tableView.estimatedRowHeight == 100)
        #expect(tableView.separatorInset == .zero)
        #expect(tableView.separatorColor == .myPurple)
    }

    @Test("present: configures the contents of the data source")
    func present() async {
        let item = FeedItem(title: "Testing", guid: "testing")
        await subject.present(MasterState(parsedData: [item]))
        #expect(subject.data == [item])
        let snapshot = subject.datasource.snapshot()
        #expect(snapshot.sectionIdentifiers == ["dummy"])
        #expect(snapshot.itemIdentifiers(inSection: "dummy") == ["testing"])
    }

    @Test("cells are correctly constructed")
    func cells() async throws {
        makeWindow(view: tableView)
        let item = FeedItem(title: "Testing", guid: "testing", blurb: "Blurb")
        await subject.present(MasterState(parsedData: [item]))
        let cell = try #require(tableView.cellForRow(at: IndexPath(row: 0, section: 0)))
        let content = try #require(cell.contentConfiguration as? MasterCellContentConfiguration)
        #expect(content.text == item.attributedSummary)
        let background = try #require(cell.backgroundConfiguration)
        #expect(background.backgroundColor == .systemBackground)
        let view = try #require(cell.contentView as? MasterCellContentView)
        #expect(view.drawer.attributedText == content.text)
    }

    @Test("didSelect: sends selected with row")
    func didSelect() async {
        subject.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.selected(0)])
    }
}

