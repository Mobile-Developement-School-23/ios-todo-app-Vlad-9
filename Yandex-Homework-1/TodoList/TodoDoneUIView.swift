import UIKit
protocol TodoDoneUIViewdelegate: AnyObject {
    func showIsDone(done: Bool)
}
class TodoDoneUIView: UIView {
    
    //MARK: - Constants
    
    enum Constraints {
      
        static let segmentedControlTopAnchorConstraintConstant: CGFloat = 12.5
        static let segmentedControlBottomAnchorConstraintConstant: CGFloat = -12.5
    }
    enum Constants {
        static let priorityLabelFontSize: CGFloat = 15
    }

    //MARK: - Dependencies

    private var showIsDone =  UIButton(type: .system)
    weak var delegate: TodoDoneUIViewdelegate?
    var flag = false

    //MARK: - UI
    
    private let mainLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.textColor = Colors.labelTeritary.value
        label.font = .systemFont(ofSize: Constants.priorityLabelFontSize, weight: .regular)
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.textColor = Colors.labelTeritary.value
        label.font = .systemFont(ofSize: Constants.priorityLabelFontSize, weight: .regular)

        return label
    }()
    //MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        conf()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure
    func conf() {
        showIsDone.setTitle("показать", for: .normal)
        showIsDone.addTarget(self, action: #selector(showTodoItems), for: .touchUpInside)
    }
    func configure(with count: Int)  {
        if count > 0 {
            self.countLabel.text = "\(count)"
            self.mainLabel.text = "Выполнено — "
        } else {
            self.mainLabel.text = "Нет выполненных дел"
            self.countLabel.text = ""
        }
       
    }
    @objc func showTodoItems() {
        if !flag {
            self.showIsDone.alpha = 0
            self.showIsDone.setTitle("скрыть", for: .normal)
            UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
                self.showIsDone.alpha = 1
            })
 
        } else {
            self.showIsDone.alpha = 0
            showIsDone.setTitle("показать", for: .normal)
            UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
                self.showIsDone.alpha = 1
            })
        }
        flag = !flag
        self.delegate?.showIsDone(done: flag).self
    }
    //MARK: - Constraints
    
    private func setupConstraints() {
     
        self.addSubview(mainLabel)
        self.addSubview(countLabel)
        self.addSubview(showIsDone)
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        showIsDone.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 16),
            mainLabel.topAnchor.constraint(equalTo: self.topAnchor,constant: 10),
            mainLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -12),
            countLabel.topAnchor.constraint(equalTo: self.topAnchor,constant: 10),
            countLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -12),
            countLabel.topAnchor.constraint(equalTo: self.topAnchor,constant: 10),
            countLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -12),
            showIsDone.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -16),
            self .countLabel.leadingAnchor.constraint(equalTo: mainLabel.trailingAnchor),
        ])
    }
}
