import SwiftUI

struct SectionView: View {
    var counter: Int
    @ObservedObject var isShow: ShowDone

    init(showDone: ShowDone, counter: Int) {
        self.isShow = showDone
        self.counter = counter
    }
    var body: some View {
        HStack(spacing: Contstants.sectionViewHeaderDefaultSpacing) {
            Text(NSLocalizedString("task.myTasksСompleted",
                                   comment: "amount of tasks"))
            .foregroundColor(Color(Colors.labelTeritary.value))
            .font(.system(size: Contstants.sectionViewTextFontSize))
            Text("\(counter)").foregroundColor(Color(Colors.labelTeritary.value))
                .font(.system(size: Contstants.sectionViewTextFontSize))
            Spacer()
            Button {
                isShow.enableButton()
            } label: {
                if !isShow.isShowEnabled {
                    Text(NSLocalizedString("task.show", comment: "")).foregroundColor(Color(Colors.colorBlue.value))
                        .font(.system(size: Contstants.sectionViewTextFontSize, weight: .semibold))
                } else {
                    Text(NSLocalizedString("task.hide", comment: "")).foregroundColor(Color(Colors.colorBlue.value))
                        .font(.system(size: Contstants.sectionViewTextFontSize, weight: .semibold))
                }
            }
        }
    }
}
