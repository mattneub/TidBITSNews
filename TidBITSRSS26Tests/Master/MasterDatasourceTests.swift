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
        #expect(tableView.allowsFocus == false)
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

    @Test("receive select: selects the row of the table view, updates the data, updates the cell configuration")
    func select() async throws {
        makeWindow(view: tableView)
        let item = FeedItem(title: "Testing", guid: "testing", blurb: "Blurb")
        await subject.present(MasterState(parsedData: [item]))
        #expect(tableView.indexPathForSelectedRow == nil)
        #expect(subject.data[0].hasBeenRead == false)
        do {
            let configuration = try #require(
                tableView.cellForRow(
                    at: IndexPath(row: 0, section: 0)
                )?.contentConfiguration as? MasterCellContentConfiguration
            )
            #expect(configuration.hasBeenRead == false)
        }
        await subject.receive(.select(0))
        #expect(tableView.indexPathForSelectedRow == IndexPath(row: 0, section: 0))
        #expect(subject.data[0].hasBeenRead == true)
        do {
            let configuration = try #require(
                tableView.cellForRow(
                    at: IndexPath(row: 0, section: 0)
                )?.contentConfiguration as? MasterCellContentConfiguration
            )
            #expect(configuration.hasBeenRead == true)
        }
    }

    @Test("cells are correctly constructed")
    func cells() async throws {
        makeWindow(view: tableView)
        let item = FeedItem(title: "Testing", guid: "testing", blurb: "Blurb")
        await subject.present(MasterState(parsedData: [item]))
        let cell = try #require(tableView.cellForRow(at: IndexPath(row: 0, section: 0)))
        let content = try #require(cell.contentConfiguration as? MasterCellContentConfiguration)
        #expect(content.text == item.attributedSummary)
        let background = try #require(cell.backgroundView)
        #expect(background.backgroundColor == .systemBackground)
        let selectedBackground = try #require(cell.selectedBackgroundView)
        #expect(selectedBackground.backgroundColor == .purple.withAlphaComponent(0.2))
        let view = try #require(cell.contentView as? MasterCellContentView)
        #expect(view.drawer.attributedText == content.text)
    }

    @Test("didSelect: sends selected with row, updates the data, updates the cell configuration")
    func didSelect() async throws {
        makeWindow(view: tableView)
        let item = FeedItem(title: "Testing", guid: "testing", blurb: "Blurb")
        await subject.present(MasterState(parsedData: [item]))
        #expect(tableView.indexPathForSelectedRow == nil)
        #expect(subject.data[0].hasBeenRead == false)
        do {
            let configuration = try #require(
                tableView.cellForRow(
                    at: IndexPath(row: 0, section: 0)
                )?.contentConfiguration as? MasterCellContentConfiguration
            )
            #expect(configuration.hasBeenRead == false)
        }
        subject.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.selected(0)])
        #expect(subject.data[0].hasBeenRead == true)
        do {
            let configuration = try #require(
                tableView.cellForRow(
                    at: IndexPath(row: 0, section: 0)
                )?.contentConfiguration as? MasterCellContentConfiguration
            )
            #expect(configuration.hasBeenRead == true)
        }
    }

    @Test("trailing swipe action is Read/Unread, handler updates data, cell, processor")
    func swipeActionHandler() async throws {
        makeWindow(view: tableView)
        let item = FeedItem(title: "Testing", guid: "testing", blurb: "Blurb")
        await subject.present(MasterState(parsedData: [item]))
        do {
            #expect(subject.data[0].hasBeenRead == false)
            let configuration = try #require(
                tableView.cellForRow(
                    at: IndexPath(row: 0, section: 0)
                )?.contentConfiguration as? MasterCellContentConfiguration
            )
            #expect(configuration.hasBeenRead == false)
        }
        do {
            let configuration = try #require(
                subject.tableView(
                    tableView,
                    trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 0)
                )
            )
            #expect(configuration.performsFirstActionWithFullSwipe == false)
            let actions = configuration.actions
            #expect(actions.count == 1)
            let action = try #require(actions.first)
            #expect(action.title == "Read")
            var completed = false
            action.handler(action, tableView, { _ in completed = true })
            #expect(completed == true)
            do {
                #expect(subject.data[0].hasBeenRead == true)
                let configuration = try #require(
                    tableView.cellForRow(
                        at: IndexPath(row: 0, section: 0)
                    )?.contentConfiguration as? MasterCellContentConfiguration
                )
                #expect(configuration.hasBeenRead == true)
            }
            await #while(processor.thingsReceived.isEmpty)
            #expect(processor.thingsReceived == [.updateHasBeenRead(true, for: 0)])
        }
        processor.thingsReceived = []
        do {
            let configuration = try #require(
                subject.tableView(
                    tableView,
                    trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 0)
                )
            )
            #expect(configuration.performsFirstActionWithFullSwipe == false)
            let actions = configuration.actions
            #expect(actions.count == 1)
            let action = try #require(actions.first)
            #expect(action.title == "Unread")
            var completed = false
            action.handler(action, tableView, { _ in completed = true })
            #expect(completed == true)
            do {
                #expect(subject.data[0].hasBeenRead == false)
                let configuration = try #require(
                    tableView.cellForRow(
                        at: IndexPath(row: 0, section: 0)
                    )?.contentConfiguration as? MasterCellContentConfiguration
                )
                #expect(configuration.hasBeenRead == false)
            }
            await #while(processor.thingsReceived.isEmpty)
            #expect(processor.thingsReceived == [.updateHasBeenRead(false, for: 0)])
        }
    }
}

