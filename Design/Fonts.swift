import UIKit

enum AppFonts {
    case largeTitle
    case title
    case headline
    case body
    case subhead
    case footnote
    var font: UIFont? {

        switch self { /*
        case .regular12:
            return UIFont(name: "Poppins-Regular", size: 12)
        case .regular14:
            return UIFont(name: "Poppins-Regular", size: 14)
        case .regular16:
            return UIFont(name: "Poppins-Regular", size: 16)
        case .regular20:
            return UIFont(name: "Poppins-Regular", size: 20)
        case .regular24:
            return UIFont(name: "Poppins-Regular", size: 24)
        case .regular32:
            return UIFont(name: "Poppins-Regular", size: 32)
        case .bold12:
            return UIFont(name: "Poppins-Bold", size: 12)
        case .bold14:
            return UIFont(name: "Poppins-Bold", size: 14)
        case .bold16:
            return UIFont(name: "Poppins-Bold", size: 16)
        case .bold20:
            return UIFont(name: "Poppins-Bold", size: 20)
        case .bold24:
            return UIFont(name: "Poppins-Bold", size: 24)
        case .bold32:
            return UIFont(name: "Poppins-Bold", size: 32)
                       */
        case .largeTitle:
           // return UIFont(name: <#T##String#>, size: <#T##CGFloat#>)
            return UIFont(name: "SFProDisplay-Bold", size: 38)
        case .title:
            return .systemFont(ofSize: 20)
        case .headline:
            return .systemFont(ofSize: 17)
        case .body:
            return .systemFont(ofSize: 16)
        case .subhead:
            return .systemFont(ofSize: 15)
        case .footnote:
            return .systemFont(ofSize: 13)
        }
    }
}
