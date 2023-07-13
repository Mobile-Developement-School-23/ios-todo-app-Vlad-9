import UIKit
import TodoItem

// MARK: - Model

struct CellModel {
    var text: String?
    var date: Date?
    var id: String
    var deadline: Date?
    var isDone: Bool
    var color: UIColor?
    var priority: TodoItem.Priority
}

protocol TodoTableViewCellDelegate: AnyObject {
    func setIsDone(id: String, indexPath: IndexPath, animation: Bool)
}

protocol TodoTableViewCellConfigurable {
    func configure(model: CellModel)
}

class TodoTableViewCell: UITableViewCell {
    enum Icon: String {
        case LowIcon = "lowPriorityIcon"
        case HighIcon = "highPriorityIcon"
        
        var image: UIImage? {return UIImage(named: rawValue)}
    }

    // MARK: - Dependencies

    weak var delegate: TodoTableViewCellDelegate?
    var deadline: Date?
    var indexp: IndexPath?
    var isDone: Bool = false
    var id: String  = ""
    var texts = ""
    var color = UIColor()
    var priority: TodoItem.Priority = .basic

    // MARK: - UI
    var icon = UIImageView()
    var chevron = UIImageView()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.font = .systemFont(ofSize: 17)
       // label.textColor = Colors.labelPrimary.value
        return label
    }()
    var dateView = DeadlineCellView()
    var radioButton = UIButton(type: .custom)

    // MARK: - Constraints

    lazy var constraintWithIcon = [icon.widthAnchor.constraint(equalTo: icon.heightAnchor,
                                                               multiplier: (Icon.HighIcon.image?.size.width)! / ((Icon.HighIcon.image?.size.height)!)),
                                   titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor,
                                                                       constant: 2),
                                   dateView.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 2)]
    lazy var constrWithoutIcon = [icon.widthAnchor.constraint(equalToConstant: 0),
                                  titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                                                      constant: 52),
                                  dateView.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                                                    constant: 52)]
    lazy var constraintWithDeadline = [        dateView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
                                               dateView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -17),
                                               titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17),
                                               titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -39)]
    
    lazy var constraintWithoutDeadline = [

        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -17),
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17),
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -39)]

    // MARK: - Inits

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    func conf() {
        self.chevron.image = UIImage(named: "chevronIcon")
        radioButton.addTarget(self, action: #selector(radioButtonTapped), for: .touchUpInside)
        radioButton.translatesAutoresizingMaskIntoConstraints = false
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deviceOrientationDidChangeNotification),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    @objc func deviceOrientationDidChangeNotification(_ notification: Any) {
        setNeedsLayout()
    }

    func setButtonImage(flag: Bool, priority: TodoItem.Priority) {
        if flag {
            self.radioButton.setImage(UIImage(named: "radioButtonIcon"), for: .normal)
            let attributedText1 = NSAttributedString(
                string: self.texts,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )

            self.priorityIconToggle(flag: false)
            self.deadlineToggle(flag: false)
            self.titleLabel.textColor = Colors.labelTeritary.value
            self.titleLabel.attributedText = attributedText1

        } else {
            if priority == .important {
                self.radioButton.setImage(UIImage(named: "radioButtonHighPriorityIcon"), for: .normal)
            } else {
                self.radioButton.setImage(UIImage(named: "radioButtonGrayIcon"), for: .normal)
               // self.radioButton.

            }
            let attributedText = NSAttributedString(
                string: self.texts,
                attributes: [.strikethroughStyle: NSUnderlineStyle.patternDot.rawValue]
            )
            if priority != .basic {
                self.priorityIconToggle(flag: true)
            }
            if self.deadline != nil {
                self.deadlineToggle(flag: true)
            }
            self.titleLabel.attributedText = attributedText
            self.titleLabel.textColor = self.color
        }
    }

    // MARK: - Configure

    @objc func radioButtonTapped() {
        self.isDone = !self.isDone
        radioButton.checkboxAnimation {
            self.setButtonImage(flag: self.isDone, priority: self.priority)
        }
        delegate?.setIsDone(id: self.id,
                            indexPath: self.indexp!,
                            animation: true).self
    }

    func configueElem() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateView.translatesAutoresizingMaskIntoConstraints = false
        dateView.setContentHuggingPriority(.defaultHigh,
                                           for: .horizontal)
        dateView.setContentCompressionResistancePriority(.defaultHigh,
                                                         for: .horizontal)
    }

    // MARK: - Layout

    private func setupUI() {
        conf()
        configueElem()
        contentView.addSubview(chevron)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateView)
        contentView.addSubview(radioButton)
        chevron.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(icon)

        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            chevron.widthAnchor.constraint(equalToConstant: 7),
            chevron.heightAnchor.constraint(equalToConstant: 12),
            chevron.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 52),
            icon.heightAnchor.constraint(equalToConstant: 20),
            icon.centerYAnchor.constraint(equalTo: radioButton.centerYAnchor)
        ])
        NSLayoutConstraint.activate(constraintWithoutDeadline)
        NSLayoutConstraint.activate(constrWithoutIcon)
        NSLayoutConstraint.activate([
            radioButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            radioButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}

// MARK: - NoteTableViewCellConfigurable

extension TodoTableViewCell: TodoTableViewCellConfigurable {

    override func prepareForReuse() {
        super.prepareForReuse()
        self.chevron.alpha = 0
        self.icon.image = nil
        self.titleLabel.textColor = .blue
    }

    func configure(model: CellModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"

        self.isDone = model.isDone
        self.id = model.id
        self.isDone = model.isDone
        self.priority = model.priority
        self.texts = model.text!

        self.color = model.color ?? Colors.labelPrimary.value
        self.deadline = model.date
        self.titleLabel.text = model.text
        if let deadline = model.date {
            dateView.isHidden = false
            dateView.configureView(text: dateFormatter.string(from: deadline))
            NSLayoutConstraint.deactivate(constraintWithoutDeadline)
            NSLayoutConstraint.activate(constraintWithDeadline)
        } else {
            dateView.isHidden = true
            dateView.configureView(text: nil)
            dateView.icon.image = nil
            NSLayoutConstraint.deactivate(constraintWithDeadline)
            NSLayoutConstraint.activate(constraintWithoutDeadline)
        }
        if priority == .important {
            icon.image = Icon.HighIcon.image

            NSLayoutConstraint.deactivate(constrWithoutIcon)
            NSLayoutConstraint.activate(constraintWithIcon)

        } else if priority == .low {
            icon.image = Icon.LowIcon.image
            NSLayoutConstraint.deactivate(constrWithoutIcon)
            NSLayoutConstraint.activate(constraintWithIcon)

        } else {
            NSLayoutConstraint.deactivate(constraintWithIcon)
            NSLayoutConstraint.activate(constrWithoutIcon)
        }
        // setupUI()
    }
    func priorityIconToggle(flag: Bool) {
        if flag {
            NSLayoutConstraint.deactivate(constrWithoutIcon)
            NSLayoutConstraint.activate(constraintWithIcon)
        } else {
            NSLayoutConstraint.deactivate(constraintWithIcon)
            NSLayoutConstraint.activate(constrWithoutIcon)
        }
    }
    func deadlineToggle(flag: Bool) {
        if flag {
            dateView.isHidden = false
            NSLayoutConstraint.deactivate(constraintWithoutDeadline)
            NSLayoutConstraint.activate(constraintWithDeadline)
        } else {
            dateView.isHidden = true
            NSLayoutConstraint.deactivate(constraintWithDeadline)
            NSLayoutConstraint.activate(constraintWithoutDeadline)
        }
    }
}
