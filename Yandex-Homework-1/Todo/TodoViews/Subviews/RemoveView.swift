import UIKit

protocol IRemoveDelegate: AnyObject {
    func userTappedRemove()
}

class RemoveView: UIView {

    // MARK: - Constants

    enum Constraints {
        static let removeButtonTopAnchorConstraintConstant: CGFloat = 17
        static let removeButtonLeadingAnchorConstraintConstant: CGFloat = 16
        static let removeButtonTrailingAnchorConstraintConstant: CGFloat = -16
        static let removeButtonBottomAnchorConstraintConstant: CGFloat = -17
    }
    enum Constants {
        static let viewCornerRadius: CGFloat = 16
        static let buttonFontSize: CGFloat = 17
        static let buttonTitle = NSLocalizedString("task.remove", comment: "remove task")
    }

    // MARK: - Dependencies

    weak var delegate: IRemoveDelegate?

    // MARK: - UI

    private  var removeButton =  UIButton(type: .system)

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
        setupButton()
        self.layer.cornerRadius = Constants.viewCornerRadius
        self.backgroundColor = Colors.backSecondary.value
    }

    private func setupButton() {
        removeButton.setTitle(Constants.buttonTitle, for: .normal)
        removeButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
        removeButton.tintColor = Colors.colorRed.value
        removeButton.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize)
    }

    // MARK: - Constraints

    private func setupConstraints() {
        self.addSubview(removeButton)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            removeButton.topAnchor.constraint(equalTo: self.topAnchor,
                                              constant: Constraints.removeButtonTopAnchorConstraintConstant),
            removeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                                  constant: Constraints.removeButtonLeadingAnchorConstraintConstant),
            removeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                   constant: Constraints.removeButtonTrailingAnchorConstraintConstant),
            removeButton.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                 constant: Constraints.removeButtonBottomAnchorConstraintConstant)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Button handler

    @objc private func remove() {
        delegate.self?.userTappedRemove()
    }
}

extension RemoveView {
     func changeState(flag: Bool) {
         if flag {
             self.removeButton.isEnabled = false
         } else {
             self.removeButton.isEnabled = true
         }
     }
 }
