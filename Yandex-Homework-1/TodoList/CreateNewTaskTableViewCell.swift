import UIKit

class CreateNewTaskTableViewCell: UITableViewCell {
    
    private enum Constants {
        static let labelNumberOfLines = 1
        static let systemFontSize:CGFloat = 17
        static let iconName = "addIcon"
    }
    private enum Constraints {
        static let iconTopBottomAnchor:CGFloat = 16
        static let iconLeadingAnchor:CGFloat = 16
        static let titlelabelTopBottomAnchor:CGFloat = 16
        static let titlelabelLeadingAnchor:CGFloat = 12
        static let titlelabelTrailingAnchor:CGFloat = 16
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = Constants.labelNumberOfLines
        label.text = NSLocalizedString("task.newTaskShort", comment: " new task")
        label.font = .systemFont(ofSize: Constants.systemFontSize)
        label.textColor = Colors.labelTeritary.value
        return label
    }()
    var icon = UIImageView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        icon.image = UIImage(named: Constants.iconName)
        addSubview(titleLabel)
        addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: self.topAnchor,
                                      constant: Constraints.iconTopBottomAnchor),
            icon.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                         constant: -Constraints.iconTopBottomAnchor),
            icon.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                          constant: Constraints.iconLeadingAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor,
                                                constant: Constraints.titlelabelLeadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                 constant: -Constraints.titlelabelTrailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor,
                                            constant: Constraints.titlelabelTopBottomAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                               constant: -Constraints.titlelabelTopBottomAnchor)
        ])
        self.selectionStyle = .none
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
