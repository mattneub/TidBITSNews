import UIKit

final class DisclosureTogglingCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        registerForTraitChanges(
            [UITraitSplitViewControllerLayoutEnvironment.self],
            action: #selector(adjustDisclosure)
        )
        adjustDisclosure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func adjustDisclosure() {
        let environment = traitCollection.splitViewControllerLayoutEnvironment
        accessoryType = environment == .collapsed ? .disclosureIndicator : .none
    }
}
