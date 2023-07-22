import SwiftUI

private enum Constants {
    static var removeButtonFontSize: CGFloat { return 17.0 }
    static var removeButtonTitlePadding: CGFloat { return 16.0 }
}

struct RemoveView: View {
    var body: some View {
        Button {
        } label: {
            Text(NSLocalizedString("task.remove", comment: "title for remove button"))
                .font(.system(size: Constants.removeButtonFontSize))
                .foregroundColor(Color(Colors.colorRed.value))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.all, Constants.removeButtonTitlePadding)
                .background(
                    Color(Colors.backSecondary.value)
                        .clipped()
                        .cornerRadius(radius: Contstants.radius, corners: .allCorners))
        }
    }
}
