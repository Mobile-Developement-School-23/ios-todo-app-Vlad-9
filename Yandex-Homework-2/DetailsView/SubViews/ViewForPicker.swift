import SwiftUI

struct ViewForPicker: View {
    var priority: Priority
    var body: some View {
        switch priority {
        case .low:
            Image("lowPriorityIcon")
        case .important:
            Image("highPriorityIcon")
        default:
            Text(NSLocalizedString("task.priorityLow", comment: "title for normal task state"))
        }
    }
}
