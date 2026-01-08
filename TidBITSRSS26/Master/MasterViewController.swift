import UIKit

class MasterViewController: UITableViewController, ReceiverPresenter {
    weak var processor: (any Receiver<MasterAction>)?

    /// Our data source object. It is lazily created when we receive our first `present` call.
    lazy var datasource: any MasterDatasourceType<MasterEffect, MasterState> = MasterDatasource(
        tableView: tableView,
        processor: processor
    )

    /// One-shot spinner, shown only during app launch before we have data to display.
    lazy var spinner = UIActivityIndicatorView(style: .large).applying {
        $0.color = .black
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    /// The table view's refresh control.
    lazy var refresher = UIRefreshControl().applying {
        $0.backgroundColor = UIColor(red: 0.251, green: 0, blue: 0.502, alpha: 1)
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(doRefresh), for: .valueChanged)
    }

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
        logo.heightAnchor.constraint(equalToConstant: 58).activate(priority: 999)
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
        refreshControl = refresher
        // show spinner during launch only
        tableView.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: tableView.frameLayoutGuide.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: tableView.frameLayoutGuide.centerYAnchor),
        ])
        spinner.startAnimating()
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        Task {
            await processor?.receive(.appearing)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            await processor?.receive(.viewDidAppear)
        }
    }

    func present(_ state: MasterState) async {
        spinner.removeFromSuperview()
        refresher.endRefreshing()
        refresher.attributedTitle = NSAttributedString(state.lastNetworkFetchDateStringAttributed ?? "")
        await datasource.present(state)
    }

    func receive(_ effect: MasterEffect) async {
        await datasource.receive(effect)
    }

    @objc func logoTapped() {
        Task {
            await processor?.receive(.logoTapped)
        }
    }

    @objc func doRefresh(_ sender: UIRefreshControl) {
        Task {
            if sender.isRefreshing {
                await processor?.receive(.fetchFeed(forceNetwork: true))
            }
        }
    }
}
