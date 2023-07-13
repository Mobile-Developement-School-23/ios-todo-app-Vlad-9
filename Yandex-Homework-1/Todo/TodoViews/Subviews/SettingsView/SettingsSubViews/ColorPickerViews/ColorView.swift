import UIKit

protocol ISwitchColorDelegate: AnyObject {
    func userTapSwitch(in position: Bool)
}

class ColorView: UIView {

    // MARK: - Constraints

    enum Constraints {

        static let switchTopAnchorConstraintConstant: CGFloat = 12.5
        static let switchBottomAnchorConstraintConstant: CGFloat = -12.5
    }
    enum Constants {
        static let priorityLabelFontSize: CGFloat = 17
        static let label = NSLocalizedString("task.color", comment: "Цвет дела")
    }

    // MARK: - Dependencies

    weak var delegate: ISwitchColorDelegate?

    // MARK: - UI

    private let switcher = UISwitch()
    private let colorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = Constants.label
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.textColor = Colors.labelPrimary.value
        label.font = .systemFont(ofSize: Constants.priorityLabelFontSize, weight: .regular)
        return label
    }()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureSwitch()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    private func configureSwitch() {
        switcher.addTarget(self, action: #selector(self.switchStateDidChange(_:)), for: .valueChanged)
        switcher.setOn(false, animated: false)
        switcher.onTintColor = Colors.colorGreen.value
    }

    // MARK: - Set constraints

    private func setupConstraints() {
        self.addSubview(colorLabel)
        self.addSubview(switcher)
        switcher.translatesAutoresizingMaskIntoConstraints = false
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            colorLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            colorLabel.centerYAnchor.constraint(equalTo: switcher.centerYAnchor),
            switcher.topAnchor.constraint(equalTo: self.topAnchor,
                                          constant: Constraints.switchTopAnchorConstraintConstant),
            switcher.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                             constant: Constraints.switchBottomAnchorConstraintConstant),
            switcher.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}

// MARK: - Switch handler
extension ColorView {

    @objc private func switchStateDidChange(_ sender:UISwitch!) {
        delegate?.userTapSwitch(in: sender.isOn)
    }
}

extension ColorView { // TODO: - Вынести в протокол
    func initiateColorSelectionView() {
        self.delegate?.userTapSwitch(in: true)
        self.switcher.isOn = true
    }
}
