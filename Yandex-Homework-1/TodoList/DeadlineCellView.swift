import UIKit

class DeadlineCellView: UIView {

    //MARK: - Constants

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
    
    //MARK: - Dependencies

    weak var delegate: IRemoveDelegate?

    //MARK: - UI
    var icon = UIImageView()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15)
        label.textColor = Colors.labelTeritary.value
        return label
    }()
   
    //MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Configuration

    func configureView(text: String?) {
        icon.image = UIImage(named: "calendarIcon")?.withTintColor(Colors.labelTeritary.value, renderingMode: .alwaysOriginal)
        self.titleLabel.text = text
        setupConstraints()
    }

    //MARK: - Constraints

    private func setupConstraints() {
        self.addSubview(titleLabel)
        self.addSubview(icon)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
       
        let constraints = [
            icon.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor,constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            icon.topAnchor.constraint(equalTo: self.topAnchor,constant: 2),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            icon.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -2),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
