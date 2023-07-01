import Foundation
import TodoItem

struct TodoViewModel {

    // MARK: - Properties

    let id: String
    var text: String
    var deadline: Date?
    var isDone: Bool
    var hexCode: String?
    var priority: TodoItem.Priority
    var dateCreated: Date
    var dateChanged: Date?

    // MARK: - Initializer

    init(
        id: String ,
        text: String,
        deadline: Date?,
        isDone: Bool,
        hexCode: String?,
        priority: TodoItem.Priority,
        dateCreated: Date ,
        dateChanged: Date?
    ) {
        self.id = id
        self.text = text
        self.deadline = deadline
        self.isDone = isDone
        self.hexCode = hexCode
        self.priority = priority
        self.dateCreated = dateCreated
        self.dateChanged = dateChanged
    }
}
