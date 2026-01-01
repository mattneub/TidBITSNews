import UIKit

class MasterViewController: UITableViewController, ReceiverPresenter {
    weak var processor: (any Receiver<MasterAction>)?

    /// Our data source object. It is lazily created when we receive our first `present` call.
    lazy var datasource: any MasterDatasourceType<Void, MasterState> = MasterDatasource(
        tableView: tableView,
        processor: processor
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor { traits in
            switch traits.userInterfaceStyle {
            case .light: UIColor.myPurple.withAlphaComponent(0.4)
            case .dark: UIColor.myPurple.withAlphaComponent(0.7)
            case .unspecified: UIColor.myPurple.withAlphaComponent(0.4)
            @unknown default: UIColor.myPurple.withAlphaComponent(0.4)
            }
        }
        let logo = MyAccessibleNoActionImageView(image: UIImage(named:"tb_iphone_banner"))
        logo.contentMode = .center
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.heightAnchor.constraint(equalToConstant: 58).activate()
        let tapper = MyTapGestureRecognizer(target: self, action: #selector(logoTapped))
        logo.addGestureRecognizer(tapper)
        logo.isUserInteractionEnabled = true
        self.navigationItem.titleView = logo
        tableView.topEdgeEffect.style = .hard
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            await processor?.receive(.viewDidAppear)
        }
    }

    func present(_ state: MasterState) async {
        await datasource.present(state)
    }

    @objc func logoTapped() {}
}
