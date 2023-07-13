import UIKit

protocol ColorSelectionViewDelegate: AnyObject {
     func userChangeColor(with color: UIColor)
 }

class ColorSelectionView: UIView {

    // MARK: - Constants

    enum Constants {
        static let brightnessMultiplier: CGFloat = 100
    }

    enum AnimationConfiguration {
        static let standardDuration: TimeInterval = 0.30
    }

    enum ViewConfiguration {
        static let paletteCornerRadius: CGFloat = 10
        static let sliderMinValue: Float = 25
        static let sliderMaxValue: Float = 100
    }

    enum Constraints {
        static let paletteHeightConstraint: CGFloat = 45
        static let standardVerticalConstraint: CGFloat = 12.5
    }

    // MARK: - Dependencies

    weak var delegate: ColorSelectionViewDelegate?
    private var color: UIColor?

    // MARK: - UI

    private var colorPalette = ColorPickerPaletteView()
    private let mySlider = UISlider()
    private lazy var hexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = NSLocalizedString("task.hex", comment: "hexcode")
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.textColor = Colors.labelPrimary.value
        label.font = .systemFont(ofSize: 17, weight: .regular)

        return label
    }()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: .zero)
        handlePaletteTap()
        configureView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private func configureView() {
        mySlider.minimumValue = ViewConfiguration.sliderMinValue
        mySlider.maximumValue = ViewConfiguration.sliderMaxValue
        mySlider.value = ViewConfiguration.sliderMaxValue
        mySlider.tintColor = Colors.colorGray.value
        mySlider.isEnabled = false
        mySlider.isContinuous = true
        mySlider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        colorPalette.layer.cornerRadius = ViewConfiguration.paletteCornerRadius
    }

    // MARK: - Constraints

    private func setupConstraints() {
        self.addSubview(colorPalette)
        self.addSubview(hexLabel)
        self.addSubview(mySlider)

        hexLabel.translatesAutoresizingMaskIntoConstraints = false
        colorPalette.translatesAutoresizingMaskIntoConstraints = false
        mySlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hexLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constraints.standardVerticalConstraint),
            hexLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorPalette.heightAnchor.constraint(equalToConstant: Constraints.paletteHeightConstraint),
            colorPalette.topAnchor.constraint(equalTo: hexLabel.bottomAnchor, constant: Constraints.standardVerticalConstraint),
            colorPalette.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorPalette.trailingAnchor.constraint(equalTo: trailingAnchor),
            mySlider.topAnchor.constraint(equalTo: colorPalette.bottomAnchor, constant: Constraints.standardVerticalConstraint),
            mySlider.leadingAnchor.constraint(equalTo: leadingAnchor),
            mySlider.trailingAnchor.constraint(equalTo: trailingAnchor),
            mySlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constraints.standardVerticalConstraint)
        ])
    }
}

// MARK: - Slider handler

extension ColorSelectionView {
    @objc func sliderValueDidChange(_ sender: UISlider!) {
        let value = sender.value / Float(Constants.brightnessMultiplier)
        self.color = color?.addBrightness(with: CGFloat(value))
        self.hexLabel.text = self.color?.toHexString()
        self.hexLabel.textColor = self.color
        self.mySlider.tintColor = self.color
        delegate?.userChangeColor(with: self.color ?? Colors.labelPrimary.value).self
    }
}

// MARK: - Palette tap handler

extension ColorSelectionView {
    func handlePaletteTap() {
        colorPalette.onColorDidChange = { [weak self] color in
            DispatchQueue.main.async {
                self?.color = color
                self?.hexLabel.text = color.toHexString()
                self?.delegate?.userChangeColor(with: color ?? Colors.labelPrimary.value).self
                self?.hexLabel.textColor = color
                self?.mySlider.tintColor = color
                UIView.animate(withDuration: AnimationConfiguration.standardDuration,
                               animations: {
                    self?.mySlider.setValue(ViewConfiguration.sliderMaxValue,
                                            animated: true)
                })
                self?.mySlider.isEnabled = true
            }
        }
    }
}

extension ColorSelectionView { // TODO: - Вынести в протокол
    func setHexColor(color: String) {
        self.color =  UIColor(hex: color) ?? Colors.labelPrimary.value
        self.mySlider.value = Float((self.color?.getBrightness() ?? 0) * Constants.brightnessMultiplier)
        self.hexLabel.text = color
        delegate?.userChangeColor(with: self.color ?? Colors.labelPrimary.value).self
        mySlider.isEnabled = true
        self.mySlider.tintColor = self.color
        self.hexLabel.textColor = self.color
    }
    func getHexColor() -> String? {
            return self.color?.toHexString()
    }
    func resetColor() {
        self.color = nil
    }
}
