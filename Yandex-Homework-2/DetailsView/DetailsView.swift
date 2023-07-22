import SwiftUI

private enum Constants {
    static var cardStackSpacing: CGFloat { return 16.0 }
    static var cardStackHorizontalSpacing: CGFloat { return 16.0 }
    static var navigationBarButtonFontSize: CGFloat { return 17.0 }
}

struct DetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    var item: TodoViewModel
    @State var text: String = ""
    init(item: TodoViewModel) {
        self.item = item
    }
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .center, spacing: Constants.cardStackSpacing, pinnedViews: [.sectionHeaders]) {
                    TextView(text: $text)
                        .padding(.horizontal, Constants.cardStackHorizontalSpacing)
                    StackView(item: item)
                        .padding(.horizontal, Constants.cardStackHorizontalSpacing)
                    RemoveView()
                        .padding(.horizontal, Constants.cardStackHorizontalSpacing)
                }
            }
            .background(Color(Colors.backPrimary.value))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(NSLocalizedString("task.title", comment: "main title"))
            .navigationBarItems(leading:
                                    Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text(NSLocalizedString("task.back",
                                       comment: "title for back button"))
                .font(.system(size: Constants.navigationBarButtonFontSize))
                .foregroundColor(Color(Colors.colorBlue.value))},
                                trailing:
                                    Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text(NSLocalizedString("task.save",
                                       comment: "title for save button"))
                .font(.system(size: Constants.navigationBarButtonFontSize,
                              weight: .semibold))
                .foregroundColor(Color(Colors.colorBlue.value))
            })
        }
        .onAppear {
            self.text = item.text
            print(item.text)
        }
    }
}
