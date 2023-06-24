import UIKit
protocol DeadlineHelperViewDelegate: AnyObject {
    func userTapDate()
}
class DeadlineHelperView: UIView {
    
    //MARK: - Constants
    
    enum AnimationConfiguration {
        static let standardDuration: TimeInterval = 0.40
        static let standardDelay: TimeInterval = 0.01
    }
    enum Constants {
        static let dateButtonFontSize: CGFloat = 13
        static let deadlineLabelFontSize: CGFloat = 17
    }
    
    //MARK: - Dependencies
    
    weak var delegate: DeadlineHelperViewDelegate?
    private var constraintWithDate: [NSLayoutConstraint] = []
    private var constraintWithoutDate: [NSLayoutConstraint] = []
    
    //MARK: - UI
    
    private lazy  var dateButton =  UIButton(type: .system)
    private lazy var deadlineLabel: UILabel = {
       let label = UILabel()
       label.translatesAutoresizingMaskIntoConstraints = false
       label.numberOfLines = 1
       label.text = "Сделать до"
       label.adjustsFontSizeToFitWidth = false
       label.textAlignment = .left
       label.textColor = Colors.labelPrimary.value
        label.font = .systemFont(ofSize: Constants.deadlineLabelFontSize, weight: .regular)
       return label
   }()
    
    //MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - setDate Handler

    @objc func setDate (){
        delegate.self?.userTapDate()
    }
    
    //MARK: - Configure constraints

    private func configureConstraints() {
        deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        dateButton.translatesAutoresizingMaskIntoConstraints = false
        constraintWithoutDate =  [
            deadlineLabel.topAnchor.constraint(equalTo: self.topAnchor),
            deadlineLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            deadlineLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            deadlineLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        constraintWithDate =  [
            deadlineLabel.topAnchor.constraint(equalTo: self.topAnchor),
            deadlineLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            deadlineLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            dateButton.topAnchor.constraint(equalTo: deadlineLabel.bottomAnchor),
            dateButton.leftAnchor.constraint(equalTo: self.leftAnchor),
            dateButton.rightAnchor.constraint(equalTo: self.rightAnchor),
            dateButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
    }
    
    //MARK: - Configure view
    
    private func configureView() {
        setupButton()
    }
    private func setupButton() {
        dateButton.contentHorizontalAlignment = .left
        dateButton.addTarget(self, action: #selector(setDate), for: .touchUpInside)
        dateButton.tintColor = Colors.colorBlue.value
        dateButton.titleLabel?.font = .boldSystemFont(ofSize: Constants.dateButtonFontSize)
    }
    
    //MARK: - Set constraints
    
    private func setupConstraints(){
        configureConstraints()
        self.addSubview(deadlineLabel)
        NSLayoutConstraint.activate(constraintWithoutDate)
    }
}

extension DeadlineHelperView {
    func addDateSubView(with date: Date,firstTime: Bool) {
        var datUpdated =  Date()
            datUpdated = date
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "d MMM y"
        
        dateButton.setTitle(formatter1.string(from: datUpdated), for: .normal)
        self.addSubview(dateButton)
        
        NSLayoutConstraint.deactivate(constraintWithoutDate)
        NSLayoutConstraint.activate(constraintWithDate)
        if !firstTime {
            UIView.animate(withDuration: AnimationConfiguration.standardDuration, delay: AnimationConfiguration.standardDelay, options: .curveEaseOut, animations: {
                self.dateButton.alpha = 1
                self.layoutIfNeeded()
            })
        } 
    }

    func removeDateSubView() {
        NSLayoutConstraint.deactivate(self.constraintWithDate)
        NSLayoutConstraint.activate(self.constraintWithoutDate)
        UIView.animate(withDuration: AnimationConfiguration.standardDuration, delay: AnimationConfiguration.standardDelay, options: .curveEaseIn, animations: {
            self.dateButton.alpha = 0
            self.layoutIfNeeded()
    
        }) { _ in
            self.dateButton.removeFromSuperview()
        }
    }
}
