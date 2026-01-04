import UIKit

/// Protocol describing the view controller's interaction with the datasource, so we can
/// mock it for testing.
protocol MasterDatasourceType<Received, State>: ReceiverPresenter, UITableViewDelegate {
    associatedtype State
    associatedtype Received
}

/// Table view data source and delegate for the view controller's table view.
final class MasterDatasource: NSObject, MasterDatasourceType {
    typealias State = MasterState
    typealias Received = MasterEffect

    /// Processor to whom we can send action messages.
    weak var processor: (any Receiver<MasterAction>)?

    /// Weak reference to the table view.
    weak var tableView: UITableView?

    /// Reuse identifier for the table view cells we will be creating.
    private let reuseIdentifier = "reuseIdentifier"

    init(tableView: UITableView, processor: (any Receiver<MasterAction>)?) {
        self.tableView = tableView
        self.processor = processor
        super.init()
        // We're going to use a diffable data source. Register the cell type, make the
        // diffable data source, and set the table view's dataSource and delegate.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        datasource = createDataSource(tableView: tableView)
        tableView.dataSource = datasource
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.separatorInset = .zero
        tableView.separatorColor = .myPurple
        tableView.allowsFocus = false // kill annoying "box" around cell when selected
    }

    /// Type alias for the type of the data source, for convenience.
    typealias DatasourceType = UITableViewDiffableDataSource<String, String>

    /// Retain the diffable data source.
    var datasource: DatasourceType!

    /// Create the data source for the table view. Done just once, at `init` time.
    func createDataSource(tableView: UITableView) -> DatasourceType {
        let datasource = DatasourceType(
            tableView: tableView
        ) { [unowned self] tableView, indexPath, identifier in
            return cellProvider(tableView, indexPath, identifier)
        }
        return datasource
    }

    func cellProvider(_ tableView: UITableView, _ indexPath: IndexPath, _ identifier: String) -> UITableViewCell? {
        let item = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let contentConfiguration = MasterCellContentConfiguration(feedItem: item)
        cell.contentConfiguration = contentConfiguration
        cell.accessoryType = .disclosureIndicator
        do {
            let view = UIView()
            view.backgroundColor = .systemBackground
            cell.backgroundView = view
        }
        do {
            let view = UIView()
            view.backgroundColor = .purple.withAlphaComponent(0.2)
            cell.selectedBackgroundView = view
        }
        return cell
    }

    func present(_ state: MasterState) async {
        await configureData(data: state.parsedData)
    }

    func receive(_ effect: MasterEffect) async {
        switch effect {
        case .select(let row):
            let indexPath = IndexPath(row: row, section: 0)
            tableView?.selectRow(
                at: indexPath,
                animated: true,
                scrollPosition: .middle
            )
            updateHasBeenRead(true, for: indexPath)
        }
    }

    var data = [FeedItem]()

    /// The data have arrived for the first time. Create the properties to hold the data
    /// and update the table. Done just once, at `present` time.
    func configureData(data: [FeedItem]) async {
        // We only need to do this once.
        let snapshot = NSDiffableDataSourceSnapshot<String, String>()
        guard snapshot.itemIdentifiers.isEmpty else {
            return
        }
        self.data = data
        await updateTable()
    }

    func updateTable(animating: Bool = false) async {
        var snapshot = datasource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections(["dummy"])
        snapshot.appendItems(data.map { $0.guid })
        await datasource?.apply(snapshot, animatingDifferences: animating)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Task {
            await processor?.receive(.selected(indexPath.row))
            updateHasBeenRead(true, for: indexPath)
        }
    }

    /// Update data model and cell when a feed item has been read or unread. Factored out because
    /// there are three different ways we might come at this: the user tapped; selection was
    /// changed programmatically; or a trailing swipe button.
    func updateHasBeenRead(_ hasBeenRead: Bool, for indexPath: IndexPath) {
        data[indexPath.row].hasBeenRead = hasBeenRead
        let configuration = MasterCellContentConfiguration(feedItem: data[indexPath.row])
        tableView?.cellForRow(at: indexPath)?.contentConfiguration = configuration
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let hasBeenRead = data[indexPath.row].hasBeenRead
        let title: String = hasBeenRead ? "Unread" : "Read"
        let action = UIContextualAction(style: .normal, title: title) { [weak self] action, view, completion in
            completion(true)
            self?.updateHasBeenRead(!hasBeenRead, for: indexPath)
            Task {
                // and tell the processor so it can keep the books
                await self?.processor?.receive(.updateHasBeenRead(!hasBeenRead, for: indexPath.row))
            }
        }
        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
