import UIKit

class RootViewController: UIViewController, ReceiverPresenter {

    weak var processor: (any Receiver<RootAction>)?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func present(_ state: RootState) async {} // TODO: Delete this module?
}

