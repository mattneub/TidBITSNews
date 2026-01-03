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
            case .dark: UIColor.myPurple * 0.8 + UIColor.black * 0.2
            default: UIColor.myPurple * 0.4 + UIColor.white * 0.6
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
