import Foundation
import TodoItem
import UIKit
extension TodoItem {
    init(fromDTO model: Todomodel){
        
        let name = TodoItem.Priority(rawValue: model.importance) ?? .basic
        self.init(id: model.id,
                  text: model.text,
                  deadline: (model.deadline != nil) ? Date(timeIntervalSince1970: TimeInterval(model.deadline!)) : nil,
                  isDone: model.done,
                  hexCode: model.color,
                  priority: name,
                  dateCreated:  Date(timeIntervalSince1970: TimeInterval(model.dateCreated)),
                  dateChanged: (model.dateChanged != nil) ? Date(timeIntervalSince1970: TimeInterval(model.dateChanged!)) : nil)
        
    }
}


struct ServerTodoListResponseDTO: Codable {
    let status: String
    let list: [Todomodel]
    let revision: Int
}
struct ServerTodoElementResponseDTO: Codable {
    let status: String
    let element: Todomodel
    let revision: Int
}

struct ServerTodoListRequestDTO: Codable {
    let status: String
    let list: [Todomodel]
}
struct ServerTodoElementRequestDTO: Codable {
    let status: String
    let element: Todomodel
}

struct Todomodel: Codable {
    let id: String
    let text: String
    let importance: String
    let deadline: Int?
    let done: Bool
    let color: String?
    let dateCreated: Int
    let dateChanged: Int?
    var updatedID:String
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadline
        case done
        case color
        case dateCreated = "created_at"
        case dateChanged = "changed_at"
        case updatedID = "last_updated_by"
    }
    
    init(id: String, text: String, importance: String, deadline: Int?, done: Bool, color: String?, dateCreated: Int, dateChanged: Int?, updatedID: String) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.done = done
        self.color = color
        self.dateCreated = dateCreated
        self.dateChanged = dateChanged
        self.updatedID = updatedID
    }
    
    init(item: TodoItem) {
        self.id = item.id
        self.text = item.text
        self.importance = item.priority.rawValue
        if let dedln = item.deadline{
            self.deadline = Int(dedln.timeIntervalSince1970)
        } else {
            self.deadline = nil
        }
        self.done = item.isDone
        self.color = item.hexCode
        self.dateCreated = Int(item.dateCreated.timeIntervalSince1970)
        if let dateChangedd = item.dateChanged{
            self.dateChanged = Int(dateChangedd.timeIntervalSince1970)
        } else {
            self.dateChanged = nil
        }
        self.updatedID = UIDevice.current.identifierForVendor!.uuidString
    }
    mutating func updateID() {
        self.updatedID = UIDevice.current.identifierForVendor!.uuidString
    }
    func convertToTodoItem() -> TodoItem{
        let name = TodoItem.Priority(rawValue: self.importance) ?? .basic
        return TodoItem(id: self.id,
                        text: self.text,
                        deadline: (deadline != nil) ? Date(timeIntervalSince1970: TimeInterval(deadline!)) : nil,
                        isDone: self.done,
                        hexCode: color,//(color != nil) ? colo : nil,
                        priority: name,
                        dateCreated: Date(timeIntervalSince1970: TimeInterval(dateCreated)),
                        dateChanged: (deadline != nil) ? Date(timeIntervalSince1970: TimeInterval(deadline!)) : nil)
    }
}
