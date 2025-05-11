import UIKit

struct Font {
    enum Weight: String {
        case regular = "BeVietnamPro-Regular"
        case medium = "BeVietnamPro-Medium"
        case semiBold = "BeVietnamPro-SemiBold"
        case bold = "BeVietnamPro-Bold"
        case extraBold = "BeVietnamPro-ExtraBold"
        case black = "BeVietnamPro-Black"
        case light = "BeVietnamPro-Light"
    }

    static func font(weight: Weight, size: CGFloat) -> UIFont {
        return UIFont(name: weight.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}

extension UIFont {
    static func font(weight: Font.Weight, size: CGFloat) -> UIFont {
        return Font.font(weight: weight, size: size)
    }
}
