import UIKit

/// Label with a top and bottom separator line.
final class DrawerLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let topLine = UIView().applying { line in
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = .myPurple
            line.heightAnchor.constraint(equalToConstant: 1).activate()
        }
        addSubview(topLine)
        NSLayoutConstraint.activate([
            topLine.topAnchor.constraint(equalTo: topAnchor),
            topLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            topLine.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        let bottomLine = UIView().applying { line in
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = .myPurple
            line.heightAnchor.constraint(equalToConstant: 1).activate()
        }
        addSubview(bottomLine)
        NSLayoutConstraint.activate([
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Outset because of the separator lines.
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        return rect.insetBy(dx: 0, dy: -2)
    }
}
