import SwiftUI

private enum Constants {

    static var defaultVstackSpacing: CGFloat { return 0.0 }
    static var defaultHorizontalPadding: CGFloat { return 16.0 }
    static var defaultVerticalSpacing: CGFloat { return 16.0 }
    static var reducedVerticalSpacing: CGFloat { return 8.0 }

    static var priorityLabelFontSize: CGFloat { return 17.0 }

    static var deadlineLabelFontSize: CGFloat { return 17.0 }
    static var calendarLabelFontSize: CGFloat { return 13.0 }

    static var segmentedControlMinWidth: CGFloat { return 150.0 }
    static var segmentedControlMaxWidth: CGFloat { return 200.0 }
}

struct StackView: View {

    @State var toogle: Bool = false
    @State var showCalendar: Bool = false
    @State private var date = Calendar.current.date(byAdding: .day, value: 1, to: Date.now)!
    @State private var priority = Priority.normal

    var dateFormatter: DateFormatter
    var item: TodoViewModel
    var priorityItems: [Priority] = [.low, .normal, .important]

    init(item: TodoViewModel) {
        self.item = item
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Contstants.dateFormatExtended
    }

    var body: some View {
        VStack(spacing: Constants.defaultVstackSpacing) {
            HStack {
                Text(NSLocalizedString("task.priority", comment: "Priority label"))
                    .font(.system(size: Constants.priorityLabelFontSize))
                    .padding(.vertical, Constants.defaultVerticalSpacing)
                    .padding(.leading, Constants.defaultHorizontalPadding)

                Spacer()
                Picker("", selection: $priority) {
                    ForEach(priorityItems, id: \.self) {
                        ViewForPicker(priority: $0)
                    }
                }.frame(minWidth: Constants.segmentedControlMinWidth,
                        maxWidth: Constants.segmentedControlMaxWidth)
                .pickerStyle(.segmented)
                    .padding(.trailing, Constants.defaultHorizontalPadding)

            }
            Divider().padding(.horizontal, Constants.defaultHorizontalPadding)
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("task.deadline", comment: "Deadline title"))
                        .font(.system(size: Constants.deadlineLabelFontSize))
                    if showCalendar {
                        Button {
                            self.toogle.toggle()
                        } label: {
                            Text(dateFormatter.string(from: date))
                                .font(.system(size: Constants.calendarLabelFontSize,
                                              weight: .semibold))
                                .foregroundColor(Color(Colors.colorBlue.value))
                        }
                    }
                }
                .padding(.vertical, showCalendar == true ?
                         Constants.reducedVerticalSpacing : Constants.defaultVerticalSpacing)
                    .padding(.leading, Constants.defaultHorizontalPadding)
                Toggle("", isOn: $showCalendar).tint(Color(Colors.colorGreen.value))
                    .padding(.trailing, Constants.defaultHorizontalPadding)
            }
            if toogle && showCalendar {
                Divider().padding(.horizontal, Constants.defaultHorizontalPadding)
                DatePicker("", selection: $date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal, Constants.defaultHorizontalPadding)
            }
        }
        .background(
            Color(Colors.backSecondary.value)
                .clipped()
                .cornerRadius(radius: Contstants.radius, corners: .allCorners))
        .onAppear {
            if let deadline = item.deadline {
                showCalendar = true
                toogle = true
                self.date = deadline
            }
            self.priority = item.priority
        }
    }
}
