import UIKit

/// Content view for the cell that displays a feed item.
class MasterCellContentView: UIView, UIContentView {

    lazy var drawer = UILabel().applying {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
    }

    lazy var hasBeenRead = UIImageView(image: UIImage(systemName: "circle.fill")).applying {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.widthAnchor.constraint(equalToConstant: 18).activate()
        $0.heightAnchor.constraint(equalToConstant: 18).activate()
    }

    /// Boilerplate.
    var appliedConfiguration: MasterCellContentConfiguration!

    /// Boilerplate.
    var configuration: any UIContentConfiguration {
        get { appliedConfiguration }
        set {
            guard let newConfig = newValue as? MasterCellContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }

    /// Boilerplate.
    init(configuration: MasterCellContentConfiguration) {
        super.init(frame: .zero)
        addSubview(drawer)
        addSubview(hasBeenRead)
        NSLayoutConstraint.activate([
            drawer.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            drawer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            drawer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            hasBeenRead.centerYAnchor.constraint(equalTo: centerYAnchor),
            hasBeenRead.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            hasBeenRead.leadingAnchor.constraint(equalTo: drawer.trailingAnchor, constant: 10),
        ])

        // boilerplate
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Boilerplate, followed by application of the configuration properties to the interface.
    func apply(configuration newConfiguration: MasterCellContentConfiguration) {
        guard appliedConfiguration != newConfiguration else { return }
        appliedConfiguration = newConfiguration
        drawer.attributedText = newConfiguration.text
        hasBeenRead.isHidden = !newConfiguration.displayHasBeenRead
    }
}

/// UIContentConfiguration for the master cell (portraying the summary info
/// for a feed item).
struct MasterCellContentConfiguration: UIContentConfiguration, Equatable {
    // settable properties

    var text: NSAttributedString?
    var displayHasBeenRead = true

    // boilerplate

    func makeContentView() -> any UIView & UIContentView {
        return MasterCellContentView(configuration: self)
    }

    func updated(for state: any UIConfigurationState) -> Self {
        return self
    }
}

extension MasterCellContentConfiguration {
    /// Initializer from a feed item.
    init(feedItem: FeedItem) {
        self.text = feedItem.attributedSummary
    }
}
