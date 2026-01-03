import UIKit

extension UIColor {
    static let myPurple = UIColor(red: 0.627, green: 0.533, blue: 0.694, alpha: 1)

    // Color combination methods from https://stackoverflow.com/a/27343293/341994

    func plus(_ color2: UIColor) -> UIColor {
        var (r1, g1, b1, a1) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        var (r2, g2, b2, a2) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))

        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        // add the components, but don't let them go above 1.0
        return UIColor(red: min(r1 + r2, 1), green: min(g1 + g2, 1), blue: min(b1 + b2, 1), alpha: (a1 + a2) / 2)
    }

    func multiplied(by multiplier: CGFloat) -> UIColor {
        var (r, g, b, a) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r * multiplier, green: g * multiplier, blue: b * multiplier, alpha: a)
    }
}

func +(color1: UIColor, color2: UIColor) -> UIColor {
    return color1.plus(color2)
}

func *(color: UIColor, multiplier: Double) -> UIColor {
    return color.multiplied(by: CGFloat(multiplier))
}
