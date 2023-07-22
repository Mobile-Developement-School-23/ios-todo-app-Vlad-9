import SwiftUI
struct DeadlineView: View {

    let dateFormatter: DateFormatter
    let date: Date
    init(date: Date) {
        self.date = date
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Contstants.dateFormat
    }
    var body: some View {
        HStack(spacing: Contstants.deadlineViewDefaultSpacing) {
            Image(uiImage: UIImage(named: "calendarIcon")!)
            Text(date, formatter: dateFormatter)
                .foregroundColor(Color(Colors.labelTeritary.value))
                .font(.system(size: Contstants.deadlineViewTextFontSize))
        }
    }
}
