import Foundation
import SQLite
import TodoItem

enum TodoDBError: Error {
    case FailedcreateTable
    case pathError
}

private extension TodoDB {
    private func setter(item: TodoItem) -> [Setter] {
        return [todoId <- item.id,
                text <- item.text,
                deadline <- item.deadline,
                isDone <- item.isDone,
                hexCode <- item.hexCode,
                priority <- item.priority.rawValue,
                datecreated <- item.dateCreated,
                datechanged <- item.dateChanged]
    }
    
    private func createTable() {
        do {
            try db!.run(todos.create(ifNotExists: true) { table in
                table.column(todoId, unique: true)
                table.column(text)
                table.column(deadline)
                table.column(isDone)
                table.column(hexCode)
                table.column(priority)
                table.column(datecreated)
                table.column(datechanged)
            })
        } catch {
            // throw TodoDBError.FailedcreateTable
            print("Unable to create table")
        }
    }
}
class TodoDB {
    
    static let instance = TodoDB()
    private let db: Connection?
    private let todos = Table("todos")
    private let todoId = Expression<String>(TodoItem.Keys.keyId.description)
    private let text = Expression<String>(TodoItem.Keys.keyText.description)
    private let deadline = Expression<Date?>(TodoItem.Keys.keyDeadline.description)
    private let isDone = Expression<Bool>(TodoItem.Keys.keyIsDone.description)
    private let hexCode = Expression<String?>(TodoItem.Keys.hexCode.description)
    private let priority = Expression<String>(TodoItem.Keys.keyPriority.description)
    private let datecreated = Expression<Date>(TodoItem.Keys.keyDateCreated.description)
    private let datechanged = Expression<Date?>(TodoItem.Keys.keyDateChanged.description)
    
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        print(path)
        do {
            db = try Connection("\(path)/Stephencelis.sqlite3") // rename
        } catch {
            db = nil
            print("Unable to open database")
        }
        createTable()
    }
    
    func getAllTodoItems() -> [TodoItem] {
        var items = [TodoItem]()
        
        do {
            for todo in try db!.prepare(self.todos) {
                items.append(TodoItem(id: todo[todoId],
                                      text: todo[text],
                                      deadline: todo[deadline],
                                      isDone: todo[isDone],
                                      hexCode: todo[hexCode],
                                      priority: TodoItem.Priority.init(rawValue: todo[priority]) ?? .basic,
                                      dateCreated: todo[datecreated],
                                      dateChanged: todo[datechanged]))
            }
        } catch {
            print("Select failed")
        }
        return items
    }
    
    func addTodo(item: TodoItem) {
        do {
            let insert = todos.insert(setter(item: item))
            try db!.run(insert)
        } catch {
            print(error)
        }
    }
    
    func deleteTodo(id: String) -> Bool {
        do {
            let todo = todos.filter(todoId == id)
            try db!.run(todo.delete())
            return true
        } catch {
            print("Delete failed")
        }
        return false
    }
    
    func updateTodo(item: TodoItem) -> Bool {
        let items = todos.filter(todoId == item.id)
        do {
            let update = items.update(
                setter(item: item))
            if try db!.run(update) > 0 {
                return true
            }
        } catch {
            print("Update failed: \(error)")
        }
        return false
    }
    
    //    func saveAll(items: [TodoItem]) {
    //        for item in items {
    //            if  updateTodo(item: item) {
    //            } else {
    //                addTodo(item: item)
    //            }
    //        }
    //    }
    func saveOrUpdate(item: TodoItem) {
        
        if  updateTodo(item: item) {
        } else {
            addTodo(item: item)
        }
    }
    func clearTable() {
        do {
            try db!.run(todos.delete())
        } catch {
            print("Update failed: \(error)")
        }
    }
    //    func reloadDBwith(items: [TodoItem]) {
    //        //self.todos.delete()
    //        do {
    //            try db!.run(todos.delete())
    //        } catch {
    //            print("Update failed: \(error)")
    //        }
    //
    //        for item in items {
    //            addTodo(item: item)
    //        }
    //    }
}
