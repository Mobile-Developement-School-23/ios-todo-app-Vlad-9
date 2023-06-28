import UIKit
protocol IScrollDelegate: AnyObject {
    func userTapDate()
}
protocol ISettingsColorDelegate: AnyObject {
    func userChangeColor(color: UIColor)
}
protocol ISettingsView {
    func setPriority(with value: Int)
    func setDeadline(with deadline: Date)
    func getPriorityRawValue() -> Int
    func getDeadline() -> Date?
    func getHexCode() -> String?
    func setHexCode(code: String)
}

class SettingsView: UIView{
    
    //MARK: - Configurations
    
    enum AnimationConfiguration {
        static let standardDuration: TimeInterval = 0.40
        static let standardDelay: TimeInterval = 0.01
    }
    
    enum StackViewConfiguration {
        static let stackViewSpacing: CGFloat = 16
    }
    enum ViewConfiguration {
        static let cornerRadius: CGFloat = 16
    }
    
    enum Constraints {
        static let separatorHeightConstraintConstant: CGFloat = 1.0 / UIScreen.main.scale// contentScaleFactor//
        static let stackViewLeadingAnchorConstraintConstant: CGFloat = 16
        static let stackViewTrailingAnchorConstraintConstant: CGFloat = -16
    }

    //MARK: - Dependencies

    private var dateFlag = false
    
    weak var delegate: IScrollDelegate?
    weak var delegateColor: ISettingsColorDelegate?
    weak var delegateSwitcher: ISwitchDeadlineDelegate?
    private var detailContainerHideConstraint: [NSLayoutConstraint] = []
    
    private lazy var separator1 = createSeparator()
    private lazy var separator2 = createSeparator()
    private lazy var separator3 = createSeparator()
    private lazy var separator4 = createSeparator()

    //MARK: - UI

    private lazy var priority: PriorityView = PriorityView()
    private lazy var deadline: DeadlineView = DeadlineView()
    private lazy var calendar: CalendarView = CalendarView()
    private lazy var colorView: ColorView = ColorView()
    private lazy var colorSelectionView: ColorSelectionView = ColorSelectionView()
    private lazy var stackView: UIStackView = {
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = .fill
        return stackView
    }()

    //MARK: - Initializer

    override init(frame: CGRect) {
        
        super.init(frame: .zero)
        self.configureView()
        self.setupConstraints()
    }

    override func layoutIfNeeded() {
        self.configureStackView()
        self.setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Configuration

    private func configureStackView() {
        stackView.addArrangedSubview(priority)
        stackView.addArrangedSubview(separator1)
        stackView.addArrangedSubview(colorView)
        stackView.addArrangedSubview(separator3)
        stackView.addArrangedSubview(deadline)
    }

    private func initialSeparatorsConfiguration() {
        self.separator2.isHidden = true
        self.separator4.isHidden = true
        self.separator4.alpha = 0
        self.separator2.alpha = 0
    }

    private func initialColorSelectionViewConfiguration() {
        self.colorSelectionView.alpha = 0
        self.colorSelectionView.isHidden = true
        self.colorSelectionView.transform = CGAffineTransform(scaleX: 1.0, y: 0.01)
    }
    private func initialCalendarConfiguration() {
        self.calendar.isHidden = true
        self.calendar.alpha = 0
    }

    private func configureView(){
        configureStackView()
        initialCalendarConfiguration()
        initialSeparatorsConfiguration()
        initialColorSelectionViewConfiguration()
        
        self.layer.cornerRadius = ViewConfiguration.cornerRadius
        self.backgroundColor = Colors.backSecondary.value
        
        colorView.delegate = self
        colorSelectionView.delegate = self
        calendar.delegate = self
        self.deadline.delegate = self
    }
    
    //MARK: - Set constraints
    
    private func setupConstraints() {
        
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                               constant: Constraints.stackViewLeadingAnchorConstraintConstant),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                constant: Constraints.stackViewTrailingAnchorConstraintConstant),
            stackView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
    }
}

//MARK: -  ISettingsView protocol

extension SettingsView: ISettingsView { //TODO: - Использовать протокол при обращении к SettingsView
    
    func setPriority(with value: Int) {
        self.priority.setPriority(with: value)
    }
    func setDeadline(with deadline: Date) {
        self.deadline.setupDeadline(with: deadline)
    }
    
    func getPriorityRawValue() -> Int {
        return priority.getPriorityRawValue()
    }
    func getDeadline() -> Date? {
        return deadline.getDeadline()
    }
    func getHexCode() -> String? {
        return colorSelectionView.getHexColor()
    }
    func setHexCode(code: String) {
        self.colorView.initiateColorSelectionView()
        self.colorSelectionView.setHexColor(color: code)
    }
}

//MARK: -  Create separator

extension SettingsView {

    private func createSeparator() -> UIView{
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.supportSeparator.value
        let constraint =  view.heightAnchor.constraint(equalToConstant:Constraints.separatorHeightConstraintConstant)
        NSLayoutConstraint.activate([constraint])
        return view
    }
}

//MARK: - ISwitchColorDelegate

extension SettingsView: ISwitchColorDelegate {
    
    func userTapSwitch(in position: Bool) {
        if position {
            self.stackView.insertArrangedSubview(self.colorSelectionView, at: 4)
            self.stackView.insertArrangedSubview(self.separator4, at: 5)
            UIView.animate(withDuration: AnimationConfiguration.standardDuration,
                           delay: AnimationConfiguration.standardDelay,
                           options: .curveEaseInOut,
                           animations: {
                self.separator4.alpha = 1
                self.colorSelectionView.alpha = 1
                self.colorSelectionView.transform = CGAffineTransform.identity
                self.separator4.isHidden = false
                self.colorSelectionView.isHidden = false
            })
            
        } else  {
            self.colorSelectionView.resetColor()
            var t = CGAffineTransform.identity
            t = CGAffineTransform(scaleX: 1.0, y: 0.01)
            UIView.animate(withDuration: AnimationConfiguration.standardDuration,
                           delay: 0,
                           options: .curveEaseIn,
                           animations: {
                self.separator4.alpha = 0
                self.colorSelectionView.transform = t
                self.colorSelectionView.alpha = 0
                self.separator4.isHidden = true
                self.colorSelectionView.isHidden = true
            }) { _ in
                self.stackView.removeArrangedSubview(self.colorSelectionView)
                self.colorSelectionView.removeFromSuperview()
                self.stackView.removeArrangedSubview(self.separator4)
                self.separator4.removeFromSuperview()
            }
        }
    }
}

//MARK: - ColorSelectionViewDelegate

extension SettingsView: ColorSelectionViewDelegate{
    func userChangeColor(with color: UIColor) {
        self.delegateColor?.userChangeColor(color: color).self
    }
    
    
}

//MARK: - ISwitchDeadlineDelegate

extension SettingsView: ISwitchDeadlineDelegate {
    
    func userTapDate(with date: Date?) {
        
        if let date {
            self.calendar.setupCalendarDate(with: date)
        }
        if detailContainerHideConstraint.isEmpty {
            detailContainerHideConstraint = [self.calendar.heightAnchor.constraint(equalToConstant: 0)]
        }
        if !dateFlag {
            self.stackView.addArrangedSubview(self.separator2)
            self.stackView.addArrangedSubview(self.calendar)
            
            UIView.animate(withDuration: AnimationConfiguration.standardDuration,
                           delay: AnimationConfiguration.standardDelay,
                           options: .curveEaseInOut,
                           animations: {
                self.separator2.alpha = 1
                self.calendar.alpha = 1
                self.separator2.isHidden = false
                self.calendar.isHidden = false
                self.colorSelectionView.delegate = self
                self.delegate?.userTapDate().self
            })
            dateFlag = true
        } else  {
            UIView.animate(withDuration: AnimationConfiguration.standardDuration,
                           delay: AnimationConfiguration.standardDelay,
                           options: .curveEaseInOut,
                           animations: {
                self.separator2.alpha = 0
                self.calendar.alpha = 0
                self.separator2.isHidden = true
                self.calendar.isHidden = true
            }) { _ in
                self.stackView.removeArrangedSubview(self.calendar)
                self.calendar.removeFromSuperview()
                self.stackView.removeArrangedSubview(self.separator2)
                self.separator2.removeFromSuperview()
            }
            dateFlag = false
        }
    }
}

//MARK: - ICalendarViewDelegate

extension SettingsView: ICalendarViewDelegate {
    func updateDate(with date: Date) {
        self.setDeadline(with: date)
    }
    
}
