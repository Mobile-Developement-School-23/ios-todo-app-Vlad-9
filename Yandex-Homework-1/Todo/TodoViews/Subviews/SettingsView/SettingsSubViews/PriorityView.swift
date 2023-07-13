import UIKit

class PriorityView: UIView {

    // MARK: - Constants

    enum Icon: String {
        case LowIcon = "lowPriorityIcon"
        case HighIcon = "highPriorityIcon"

        var image: UIImage? {return UIImage(named: rawValue)}
    }

    enum Constraints {

        static let segmentedControlTopAnchorConstraintConstant: CGFloat = 12.5
        static let segmentedControlBottomAnchorConstraintConstant: CGFloat = -12.5
    }
    enum Constants {
        static let priorityLabelFontSize: CGFloat = 17
    }

    // MARK: - UI

    private let segmentedControl = UISegmentedControl()
    private let priorityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = NSLocalizedString("task.priority", comment: "priority")
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.textColor = Colors.labelPrimary.value
        label.font = .systemFont(ofSize: Constants.priorityLabelFontSize, weight: .regular)

        return label
    }()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureSegmentedControl()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    private func configureSegmentedControl() {
        segmentedControl.insertSegment(with: Icon.LowIcon.image, at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: NSLocalizedString("task.priorityLow",
                                                                    comment: "low priority"),
                                       at: 1,
                                       animated: false)
        segmentedControl.insertSegment(with: Icon.HighIcon.image, at: 2, animated: false)
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.backgroundColor = Colors.supportOverlay.value
        segmentedControl.selectedSegmentTintColor = Colors.backElevated.value
//        segControl.addTarget(self, action: #selector(segControlValueChanged), for: .valueChanged)
//        segControl.addTarget(self, action: #selector(segControlValueChanged), for: .touchUpInside)
    }
    // MARK: - Constraints
    
    private func setupConstraints() {
     
        self.addSubview(priorityLabel)
        self.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        priorityLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            priorityLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            priorityLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            priorityLabel.centerYAnchor.constraint(equalTo: segmentedControl.centerYAnchor),
            segmentedControl.topAnchor.constraint(equalTo: self.topAnchor,
                                                  constant: Constraints.segmentedControlTopAnchorConstraintConstant),
            segmentedControl.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                     constant: Constraints.segmentedControlBottomAnchorConstraintConstant),
            segmentedControl.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}

extension PriorityView { // TODO: - Вынести в протокол
    func setPriority(with value: String) {
        var index = 1
        if value == "low" {
            index = 0
        } else if value == "important" {
            index = 2
        }
        self.segmentedControl.selectedSegmentIndex = index // value
    }
    func getPriorityRawValue() -> Int {
        return segmentedControl.selectedSegmentIndex
    }
}
