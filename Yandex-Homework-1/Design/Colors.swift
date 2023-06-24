import UIKit

enum Colors {
    case supportSeparator
    case supportOverlay
    case supportNavBarBlur
    case labelPrimary
    case labelSecondary
    case labelTeritary
    case labelDisable
    case colorRed
    case colorGreen
    case colorBlue
    case colorGray
    case colorGrayLight
    case colorWhite
    case backiOSPrimary
    case backPrimary
    case backSecondary
    case backElevated
    
    var value: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
               
            case .light:
                switch self {
                case .supportSeparator:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
                case .supportOverlay:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.06)
                case .supportNavBarBlur:
                    return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.8)
                case .labelPrimary:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                case .labelSecondary:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
                case .labelTeritary:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
                case .labelDisable:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.15)
                case .colorRed:
                    return UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
                case .colorGreen:
                    return UIColor(red: 0.2, green: 0.78, blue: 0.35, alpha: 1.0)
                case .colorBlue:
                    return UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
                case .colorGray:
                    return UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 1.0)
                case .colorGrayLight:
                    return UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1.0)
                case .colorWhite:
                    return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                case .backiOSPrimary:
                    return UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
                case .backPrimary:
                    return UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
                case .backSecondary:
                    return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                case .backElevated:
                    return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                }
                // 3
                
            default:
                // 4
                switch self {
                case .supportSeparator:
                    return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
                case .supportOverlay:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.32)
                case .supportNavBarBlur:
                    return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.9)
                case .labelPrimary:
                    return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                case .labelSecondary:
                    return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
                case .labelTeritary:
                    return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4)
                case .labelDisable:
                    return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.15)
                case .colorRed:
                    return UIColor(red: 1.0, green: 0.27, blue: 0.23, alpha: 1.0)
                case .colorGreen:
                    return UIColor(red: 0.2, green: 0.84, blue: 0.29, alpha: 1.0)
                case .colorBlue:
                    return UIColor(red: 0.04, green: 0.52, blue: 1.0, alpha: 1.0)
                case .colorGray:
                    return UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 1.0)
                case .colorGrayLight:
                    return UIColor(red: 0.28, green: 0.28, blue: 0.29, alpha: 1.0)
                case .colorWhite:
                    return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                case .backiOSPrimary:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                case .backPrimary:
                    return UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1.0)
                case .backSecondary:
                    return UIColor(red: 0.14, green: 0.14, blue: 0.16, alpha: 1.0)
                case .backElevated:
                    return UIColor(red: 0.23, green: 0.23, blue: 0.25, alpha: 1.0)
                }
            }
            //    switch self {
            /* case .white:
             return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
             case .whiteBackground:
             return UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
             case .gray:
             return UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
             case .neutral90:
             return UIColor(red: 48/255, green: 48/255, blue: 48/255, alpha: 1)
             case .neutral10:
             return UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1)
             case .primary50:
             return UIColor(red: 226/255, green: 62/255, blue: 62/255, alpha: 1)
             case .neutral40:
             return UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 1)
             case .primary40:
             return UIColor(red: 238/255, green: 139/255, blue: 139/255, alpha: 1)
             case .rating100:
             return UIColor(red: 255/255, green: 182/255, blue: 97/255, alpha: 1)
             */
            //    }
        }
    }
    
    var cgColor: CGColor {
        return self.value.cgColor
    }
}
