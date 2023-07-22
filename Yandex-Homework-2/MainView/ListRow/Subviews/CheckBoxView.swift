import SwiftUI

struct CheckBoxView: View {
    @Binding var isCheck: Bool
    var priority: Priority
    var body: some View {
        Button {
            isCheck.toggle()
        } label: {
            if isCheck {
                Image(uiImage: UIImage(named: "radioButtonIcon")!)
            } else {
                if priority == .important {
                    Image(uiImage: UIImage(named: "radioButtonHighPriorityIcon")!)
                } else {
                    Image(uiImage: UIImage(named: "radioButtonGrayIcon")!)
                }
            }
        }.buttonStyle(BorderlessButtonStyle())
    }
}
