import SwiftUI
import TodoItem

struct TodoViewModel: Identifiable {
    let id: String
    let text: String
    var isDone: Bool
    let hexCode: String? = nil
    let priority: Priority
    let deadline: Date?
}

enum Priority {
    case low
    case normal
    case important
}

struct ContentView: View {
    @State private var showingSheet = false
    @State var selectedItem: TodoViewModel?
    @ObservedObject var isShow = ShowDone()
    @State var list = [
        TodoViewModel(id: "1",
                      text: "Test",
                      isDone: false,
                      priority: .important,
                      deadline: Date()),
        TodoViewModel(id: "2",
                      text: "TEXT TEXTTEXT] Info.plist contained no UISceneTE] Info.plist contained no UISceneXTTET0",
                      isDone: false,
                      priority: .low,
                      deadline: nil),
        TodoViewModel(id: "3",
                      text: "Test 2",
                      isDone: true,
                      priority: .important,
                      deadline: nil),
        TodoViewModel(id: "4",
                      text: "Test 3",
                      isDone: false,
                      priority: .normal,
                      deadline: nil),
        TodoViewModel(id: "5",
                      text: "Test 3",
                      isDone: false,
                      priority: .low,
                      deadline: nil)]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                List {
                    Section {
                        ForEach($list, id: \.id) { $list in
                            if checkFirstElement(id: list.id, flag: isShow.isShowEnabled) {
                                ListRowView(isShow: isShow, list: $list).listRowBackground(
                                    Color(Colors.backSecondary.value)
                                        .clipped()
                                        .cornerRadius(radius: Contstants.radius, corners: .topLeft)
                                        .cornerRadius(radius: Contstants.radius, corners: .topRight))
                                .swipeActions(edge: .leading) {
                                    LeadingSwipeView(isCheck: $list.isDone)
                                }
                                .swipeActions(edge: .trailing) {
                                    TrailingSwipeView(list: self.$list, id: list.id)
                                }
                                .listRowInsets(Contstants.insets)
                                .alignmentGuide(.listRowSeparatorLeading) { _ in
                                    return Contstants.separatorLeadingInster
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedItem = list
                                }
                            } else {
                                ListRowView(isShow: isShow, list: $list)
                                    .listRowBackground(
                                        Color(Colors.backSecondary.value)).swipeActions(edge: .leading) {
                                            LeadingSwipeView(isCheck: $list.isDone)
                                        }
                                        .swipeActions(edge: .trailing) {
                                            TrailingSwipeView(list: self.$list, id: list.id)
                                        }.listRowInsets(Contstants.insets)
                                    .alignmentGuide(.listRowSeparatorLeading) { _ in
                                        return Contstants.separatorLeadingInster
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedItem = list
                                    }
                            }
                        }
                        HStack(spacing: Contstants.cellDefaultSpacing) {
                            Image(uiImage: UIImage(named: "addIcon")!)
                            Text(NSLocalizedString("task.newTaskShort",
                                                   comment: " New task title"))
                            .foregroundColor(Color(Colors.labelPrimary.value))
                            Button {
                                selectedItem = TodoViewModel(id: UUID().uuidString,
                                                             text: "",
                                                             isDone: false,
                                                             priority: .normal,
                                                             deadline: nil)
                            } label: {
                            }
                        }
                        .listRowBackground(ViewCellCorners(flag: listIsEmpty(flag: isShow.isShowEnabled)).body)
                        .listRowInsets(Contstants.insets)
                    }
                header: {
                    SectionView(showDone: isShow, counter: list.filter({$0.isDone}).count)
                        .textCase(nil)
                        .listRowInsets(Contstants.sectionViewHeaderInsets)
                }
                }
                .sheet(item: $selectedItem) { item in
                    DetailsView(item: item)
                }
                .background(Color(Colors.backPrimary.value))
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
                .navigationTitle(Text(NSLocalizedString("task.myTasks", comment: "Main title")))
                Button {
                    selectedItem = TodoViewModel(id: UUID().uuidString,
                                                 text: "",
                                                 isDone: false,
                                                 priority: .normal,
                                                 deadline: nil)
                    
                } label: {
                    Image(systemName: Contstants.plusButtonImageName)
                        .font(.system(size: Contstants.plusButtonPointSize, weight: .semibold))
                        .frame(width: Contstants.plusButtonFrameSize, height: Contstants.plusButtonFrameSize)
                        .foregroundColor(.white)
                        .background(Color(Colors.colorBlue.value))
                        .cornerRadius(Contstants.plusButtonCornerRadius)
                        .shadow(radius: Contstants.plusButtonshadowRadius)
                        .shadow(color: Color(Colors.colorBlue.value)
                            .opacity(Double(Contstants.plusButtonshadowOpacity))
                                , radius: Contstants.plusButtonshadowRadius, x: 0, y: 8)
                }
            }
            .onAppear {
            }
        }
    }
    func checkFirstElement (id: String, flag: Bool) -> Bool {
        if flag {
            return self.list.first?.id == id
        } else {
            return self.list.first(where: {$0.isDone == false})?.id == id
        }
    }
    func listIsEmpty ( flag: Bool) -> Bool {
        if flag {
            return self.list.count == 0
        } else {
            return !self.list.contains( where: {$0.isDone == false})
        }
    }
}

struct ViewCellCorners {
    var flag: Bool
    var body: some View {
        if flag {
            return (Color(Colors.backSecondary.value)
                .cornerRadius(radius: Contstants.radius, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight]))
        }
        return Color(Colors.backSecondary.value)
            .cornerRadius(radius: Contstants.radius, corners: [.bottomRight, .bottomLeft])
    }
}

class ShowDone: ObservableObject {
    @Published var isShowEnabled = false
    func enableButton() {
        isShowEnabled = !isShowEnabled
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
