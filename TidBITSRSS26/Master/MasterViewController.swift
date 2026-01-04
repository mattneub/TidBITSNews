import UIKit

class MasterViewController: UITableViewController, ReceiverPresenter {
    weak var processor: (any Receiver<MasterAction>)?

    /// Our data source object. It is lazily created when we receive our first `present` call.
    lazy var datasource: any MasterDatasourceType<MasterEffect, MasterState> = MasterDatasource(
        tableView: tableView,
        processor: processor
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor { traits in
            switch traits.userInterfaceStyle {
            case .dark: .myPurple * 0.8 + .black * 0.2
            default: .myPurple * 0.4 + .white * 0.6
            }
        }
        let logo = MyAccessibleNoActionImageView(image: UIImage(named:"tb_iphone_banner"))
        logo.contentMode = .center
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.heightAnchor.constraint(equalToConstant: 58).activate()
        let tapper = MyTapGestureRecognizer(target: self, action: #selector(logoTapped))
        logo.addGestureRecognizer(tapper)
        logo.isUserInteractionEnabled = true
        navigationItem.titleView = logo
        navigationItem.title = "TidBITS"
        let backButton = UIBarButtonItem(title: "TidBITS", image: nil, target: nil, action: nil)
        backButton.tintColor = .myPurple
        navigationItem.backBarButtonItem = backButton
        tableView.topEdgeEffect.style = .hard
        clearsSelectionOnViewWillAppear = false
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

    func receive(_ effect: MasterEffect) async {
        await datasource.receive(effect)
    }

    @objc func logoTapped() {}
}
