import UIKit

protocol ITextViewDelegate: AnyObject {
    func returnText()
}
class TextView: UIView {
    
    // MARK: - Constraints
    
    enum Constraints {
        static let heightAnchorConstraintConstant: CGFloat = 120
        static let textViewTopAnchorConstraintConstant: CGFloat = 12
        static let textViewLeadingAnchorConstraintConstant: CGFloat = 12
        static let textViewTrailingAnchorConstraintConstant: CGFloat = -16
        static let textViewBottomAnchorConstraintConstant: CGFloat = -12
    }
    enum ViewConfiguration {
        static let viewCornerRadius: CGFloat = 16
    }
    
    enum Constants {
        static let textViewFontSize: CGFloat = 15
    }
    
    // MARK: - Dependencies
    
    weak var delegate: ITextViewDelegate?
    private var flag = true
    // MARK: - UI
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: Constants.textViewFontSize)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.allowsEditingTextAttributes = true
        textView.backgroundColor = Colors.backSecondary.value
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 17)
        return textView
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
    
    //MARK: - Constraints
    
    private func setupConstraints() {
        
        self.addSubview(textView)
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            
            self.heightAnchor.constraint(greaterThanOrEqualToConstant:
                                            Constraints.heightAnchorConstraintConstant),
            textView.topAnchor.constraint(equalTo: self.topAnchor,
                                          constant: Constraints.textViewTopAnchorConstraintConstant),
            textView.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                              constant: Constraints.textViewLeadingAnchorConstraintConstant),
            textView.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                               constant: Constraints.textViewTrailingAnchorConstraintConstant),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                             constant: Constraints.textViewBottomAnchorConstraintConstant)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    //MARK: - Configure
    
    private func configureView() {

        self.textView.delegate = self
       // textView.textColor = Colors.labelTeritary.value
        self.backgroundColor = Colors.backSecondary.value
        self.layer.cornerRadius = ViewConfiguration.viewCornerRadius
    }
}

//MARK: - Configuration

extension TextView { //TODO: - Вынести в протокол
    
    func configureText(with text: String) {
        self.textView.text = text
        if text == "" {
            textView.text = NSLocalizedString("placeholder.title", comment: "text for placeholder")
            textView.textColor = Colors.labelTeritary.value
        } else {
            flag = false
        }
    }
    func getText() -> String {
        if !flag {
            return(textView.text)
        } else {
            return String()
        }
       
    }
    func resign()
    {
        self.textView.resignFirstResponder()
    }
}
extension TextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if flag {
            textView.text = nil
            textView.textColor = Colors.labelPrimary.value
            flag = false
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = NSLocalizedString("placeholder.title", comment: "text for placeholder")
            textView.textColor = Colors.labelTeritary.value
            flag = true
        }
    }
}
