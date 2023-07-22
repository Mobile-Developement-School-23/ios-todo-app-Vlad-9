import SwiftUI

struct LeadingSwipeView: View {
    @Binding var isCheck: Bool
    var body: some View {
        Button {
            isCheck.toggle()
        } label: {
            Image("actionRadioButtonIcon")
        }
        .tint(isCheck ? Color(Colors.colorGrayLight.value) : Color(Colors.colorGreen.value))
    }
}

struct TrailingSwipeView: View {
    @Binding var list: [TodoViewModel]
    var id: String
    var body: some View {
        Button(role: .destructive) {
            list.removeAll(where: {$0.id == id})
        } label: {
            Image(systemName: "trash.fill")
        }
        Button {
        } label: {
            Image("infoIcon")
        }
        .tint(Color(Colors.colorGrayLight.value))
    }
}
