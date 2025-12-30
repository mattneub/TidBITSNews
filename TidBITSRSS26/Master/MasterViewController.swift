import UIKit

class MasterViewController: UITableViewController, ReceiverPresenter {
    weak var processor: (any Receiver<MasterAction>)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
    }

    func present(_ state: MasterState) async {}

}
