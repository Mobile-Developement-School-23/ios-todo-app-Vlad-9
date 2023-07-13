import UIKit

protocol ICalendarViewDelegate: AnyObject {
    func updateDate(with date: Date)
}

class CalendarView: UIView {
    // MARK: - Dependencies
    weak var delegate: ICalendarViewDelegate?
    // MARK: - UI
    private var datePicker = UIDatePicker()
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setupCalendar()
        self.setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - SetupCalendarPicker
    private func setupCalendar() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.locale = Locale.autoupdatingCurrent
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
    }
    // MARK: - Set constraints
    private func setupConstraints() {
        self.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    // MARK: - DatePicker handler
    @objc func datePickerChanged(_ sender: UISegmentedControl) {
        delegate?.updateDate(with: self.datePicker.date).self
    }
}
extension CalendarView { // TODO: - Вынести в протокол
    func setupCalendarDate(with date: Date) {
        self.datePicker.date = date
    }
}
