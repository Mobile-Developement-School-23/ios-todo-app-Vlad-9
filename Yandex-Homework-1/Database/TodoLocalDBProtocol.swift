import Foundation
import TodoItem

protocol TodoLocalDBProtocol {
    func getAllTodoItems() -> [TodoItem]
    func addTodo(_ item: TodoItem)
    func updateTodo(with item: TodoItem) -> Bool
    func deleteTodo(id: String) -> Bool
    func saveOrUpdate(item _: TodoItem)
    func clearTable()
}
