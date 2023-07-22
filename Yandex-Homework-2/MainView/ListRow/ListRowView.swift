import SwiftUI

struct ListRowView: View {
    @ObservedObject var isShow: ShowDone
     @Binding var list: TodoViewModel

    func shouldItemBeInList(taskCompleted: Bool, showAllFlag: Bool) -> Bool {
        if showAllFlag {
            return true
        } else {
            if taskCompleted {
                return false
            } else {
                return true
            }
        }
    }
    var body: some View {
        if shouldItemBeInList(taskCompleted: list.isDone, showAllFlag: isShow.isShowEnabled) {
            HStack(spacing: Contstants.cellDefaultSpacing) {
                CheckBoxView(isCheck: $list.isDone, priority: list.priority)
                HStack(spacing: Contstants.priorityImageDefaultSpacing) {
                    if !list.isDone {
                        if list.priority == .low {
                            Image(uiImage: UIImage(named: "lowPriorityIcon")!)
                        } else if list.priority == .important {
                            Image(uiImage: UIImage(named: "highPriorityIcon")!)
                        }
                    }
                    VStack(alignment: .leading, spacing: Contstants.textWithDeadlineDefaultSpacing) {
                        Text(list.text)
                            .padding(.top,
                                     (list.deadline != nil && !list.isDone) ?
                                     Contstants.textVerticalPaddingWithDeadline : Contstants.textVerticalPadding)
                            .padding(.bottom,
                                     (list.deadline != nil && !list.isDone) ?
                                     Contstants.textWithDeadlineDefaultSpacing : Contstants.textVerticalPadding)
                            .foregroundColor(list.isDone ?
                                             Color(Colors.labelTeritary.value) : Color(Colors.labelPrimary.value))
                            .lineLimit(Contstants.textLineLimit)
                            .strikethrough(list.isDone)
                        if let deadline = list.deadline {
                            if !list.isDone {
                                DeadlineView(date: deadline)
                                    .padding(.bottom, Contstants.textVerticalPaddingWithDeadline)
                            }
                        }
                    }
                }
                Spacer()
                Image(uiImage: UIImage(named: "chevronIcon")!)
            }
        }
    }
}
