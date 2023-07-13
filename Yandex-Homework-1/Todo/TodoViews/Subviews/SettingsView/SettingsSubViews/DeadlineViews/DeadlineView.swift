import UIKit
protocol ISwitchDeadlineDelegate: AnyObject {
    func userTapDate(with date: Date?)
}

class DeadlineView: UIView {

    // MARK: - Constants

    enum Constraints {
        static let deadLineTitleViewTrailingAnchorConstraintConstant: CGFloat = -79
        static let switcherLeadingAnchorConstraintConstant: CGFloat = 16
        static let switcherTopAnchorConstraintConstant: CGFloat = 12.5
        static let switcherBottomAnchorConstraintConstant: CGFloat = -12.5
    }

    // MARK: - Dependencies

    private var flag = 0
    private var deadline: Date?
    weak var delegate: ISwitchDeadlineDelegate?

    // MARK: - UI

    private var deadlineTitleView = DeadlineHelperView()
    private let switcher = UISwitch()

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

    func configureView() {
        deadlineTitleView.delegate = self
        configureSwitch()
    }
    func configureSwitch() {
        switcher.addTarget(self, action: #selector(self.switchStateDidChange(_:)), for: .valueChanged)
        switcher.setOn(false, animated: false)
        switcher.onTintColor = Colors.colorGreen.value
    }

    // MARK: - Set constraints

    func setupConstraints() {

        self.addSubview(switcher)
        self.addSubview(deadlineTitleView)
        deadlineTitleView.translatesAutoresizingMaskIntoConstraints = false
        switcher.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deadlineTitleView.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                        constant: Constraints.deadLineTitleViewTrailingAnchorConstraintConstant),
            deadlineTitleView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            deadlineTitleView.centerYAnchor.constraint(equalTo: switcher.centerYAnchor),

            switcher.leadingAnchor.constraint(greaterThanOrEqualTo: deadlineTitleView.trailingAnchor,
                                              constant: Constraints.switcherLeadingAnchorConstraintConstant),
            switcher.topAnchor.constraint(equalTo: self.topAnchor,
                                          constant: Constraints.switcherTopAnchorConstraintConstant),
            switcher.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                             constant: Constraints.switcherBottomAnchorConstraintConstant),
            switcher.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}

// MARK: - switch handler

extension DeadlineView {
    @objc func switchStateDidChange(_ sender:UISwitch!) {
        if (sender.isOn == true) {
            deadline = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            self.deadlineTitleView.addDateSubView(with: deadline ?? Date(),firstTime: false)
        }
        else {
            self.deadline = nil
            self.deadlineTitleView.removeDateSubView()
            if flag == 1 {
                delegate.self?.userTapDate(with: deadline)
                flag = 0
            }
        }
    }
}

// MARK: - DeadlineHelverViewDelegate protocol

extension DeadlineView: DeadlineHelperViewDelegate {
    func userTapDate () {
        if flag == 0 {
            delegate.self?.userTapDate(with: deadline)
            flag = 1
        } else {
            delegate.self?.userTapDate(with: deadline)
            flag = 0
        }
    }
}

extension DeadlineView { // TODO: - Вынести в протокол
    func setupDeadline(with deadline: Date) {
        self.switcher.isOn = true
        self.deadline = deadline
            self.deadlineTitleView.addDateSubView(with: deadline, firstTime: true)
    }

    func getDeadline() -> Date? {
        return deadline
    }
}
