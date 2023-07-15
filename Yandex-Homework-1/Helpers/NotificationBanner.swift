import Foundation
import UIKit

class NotificationBanner: UIView {
    
    // MARK: - Constants
    
    enum Constraints {
        static let topAnchorConstraintConstant: CGFloat = 1
        static let leadingAnchorConstraintConstant: CGFloat = 10
        static let trailingAnchorConstraintConstant: CGFloat = -10
        static let bottomAnchorConstraintConstant: CGFloat = -1
    }
    enum Constants {
        static let viewCornerRadius: CGFloat = 7
    }

    // MARK: - UI
    private lazy var taskLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = ""
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 11)
        label.textColor = Colors.colorWhite.value
        return label
    }()
    
    func setValue(text: String) {
        self.taskLabel.text = text
    }
    func setColor(color: UIColor) {
        self.backgroundColor = color
    }
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureView()
        setupConstraints()
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    private func configureView() {
        self.layer.cornerRadius = Constants.viewCornerRadius
        self.backgroundColor = Colors.colorRed.value.withAlphaComponent(0.9)
    }

    // MARK: - Constraints
    
    private func setupConstraints() {
        self.addSubview(taskLabel)
        taskLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            taskLabel.topAnchor.constraint(equalTo: self.topAnchor,
                                              constant: Constraints.topAnchorConstraintConstant),
            taskLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                                  constant: Constraints.leadingAnchorConstraintConstant),
            taskLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                   constant: Constraints.trailingAnchorConstraintConstant),
            taskLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                 constant: Constraints.bottomAnchorConstraintConstant)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
