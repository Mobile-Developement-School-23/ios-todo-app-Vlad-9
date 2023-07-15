import Foundation
import UIKit

extension UIButton {
    func checkboxAnimation(closure: @escaping () -> Void) {
        guard let image = self.imageView else {return}
        UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
            image.alpha = 1
            image.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }
        ){(success) in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                self.isSelected = !self.isSelected
                image.alpha = 0
                closure()
                image.transform = .identity
                image.alpha = 1
            }, completion: nil)
        }
    }
}
