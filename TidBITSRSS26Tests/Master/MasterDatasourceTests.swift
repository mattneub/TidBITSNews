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
    }

    @Test("present: configures the contents of the data source")
    func present() async {
        let item = MockFDPItem()
        item._guid = "testing"
        item._title = "Testing"
        await subject.present(MasterState(parsedData: [item]))
        #expect(subject.data == [item])
        let snapshot = subject.datasource.snapshot()
        #expect(snapshot.sectionIdentifiers == ["dummy"])
        #expect(snapshot.itemIdentifiers(inSection: "dummy") == ["testing"])
    }

    @Test("cells are correctly constructed")
    func cells() async throws {
        makeWindow(view: tableView)
        let item = MockFDPItem()
        item._guid = "testing"
        item._title = "Testing"
        await subject.present(MasterState(parsedData: [item]))
        let cell = try #require(tableView.cellForRow(at: IndexPath(row: 0, section: 0)))
        let content = try #require(cell.contentConfiguration as? UIListContentConfiguration)
        #expect(content.text == "Testing")
    }
}

nonisolated
private final class MockFDPItem: FDPItem {
    var _guid: String = ""
    var _title: String = ""
    override var guid: String { _guid }
    override var title: String { _title }
}
