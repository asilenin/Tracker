import UIKit

extension UIColor {

    // MARK: - Init from hex string (#RRGGBB or RRGGBB)
    convenience init(hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255
        let blue = CGFloat(rgbValue & 0x0000FF) / 255

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

    // MARK: - Convert UIColor to #RRGGBB string
    var hexString: String {
        guard let components = cgColor.components else {
            return "#000000"
        }

        let r: CGFloat
        let g: CGFloat
        let b: CGFloat

        if components.count >= 3 {
            r = components[0]
            g = components[1]
            b = components[2]
        } else {
            let gray = components[0]
            r = gray
            g = gray
            b = gray
        }

        return String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
    }
}
