import SwiftUI

private enum Constants {
    static var textViewFrameMinHeight: CGFloat { return 120.0 }
    static var textViewHorizontalPadding: CGFloat { return 16.0 }
    static var textViewVerticalPadding: CGFloat { return 12.0 }
}

struct TextView: View {
    @Binding var text: String
    var body: some View {
        TextEditor(text: $text)
            .frame(minHeight: Constants.textViewFrameMinHeight)
            .padding(.horizontal, Constants.textViewHorizontalPadding)
            .padding(.vertical, Constants.textViewVerticalPadding)
            .background(
                Color(Colors.backSecondary.value)
                    .clipped()
                    .cornerRadius(radius: Contstants.radius, corners: .allCorners))
    }
}
