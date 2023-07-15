import CoreData
import UIKit
import TodoItem

final class TodoCoreData {

    private enum Constants {
        static let entityName = "Todo"
        static let predicateFormat = "id == %@"
        static let persistentContainerName = "Yandex-Homework-1"
    }

    static let shared = TodoCoreData()
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.persistentContainerName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private func saveContext () {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    private func converterToTodoItem(item: Todo) -> TodoItem {
        return TodoItem(id: item.id!,
                        text: item.text!,
                        deadline: item.deadline,
                        isDone: item.isDone,
                        hexCode: item.hexCode,
                        priority: TodoItem.Priority.init(rawValue: item.priority!) ?? .basic,
                        dateCreated: item.datecreated!,
                        dateChanged: item.datechanged,
                        updatedID: item.updatedID ?? UIDevice.current.identifierForVendor!.uuidString)
    }
}

// MARK: - TodoDatabaseProtocol

extension TodoCoreData: TodoLocalDBProtocol {

    func getAllTodoItems() -> [TodoItem] {
        var array: [TodoItem] = []
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        let items = try! viewContext.fetch(fetchRequest)
        for item in items {
            array.append(converterToTodoItem(item: item))
        }
        return array
    }

    func addTodo(_ item: TodoItem) {
        let todo = Todo(context: viewContext)
        todo.id = item.id
        todo.priority = item.priority.rawValue
        todo.hexCode = item.hexCode
        todo.isDone = item.isDone
        todo.deadline = item.deadline
        todo.text = item.text
        todo.datechanged = item.dateChanged
        todo.datecreated = item.dateCreated
        todo.updatedID = item.updatedID
        saveContext()
    }

    func updateTodo(with item: TodoItem) -> Bool {
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: Constants.predicateFormat, "\(item.id)")
        let objects = try! viewContext.fetch(fetchRequest)
        for todo in objects {
            todo.priority = item.priority.rawValue
            todo.hexCode = item.hexCode
            todo.isDone = item.isDone
            todo.deadline = item.deadline
            todo.text = item.text
            todo.datechanged = item.dateChanged
            todo.datecreated = item.dateCreated
            todo.updatedID = item.updatedID
        }
        if objects.count == 0 {
            return false
        }
        do {
            try viewContext.save()
            return true
        } catch {
            return false
        }
    }

    func deleteTodo(id: String) -> Bool {
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: Constants.predicateFormat, "\(id)")
        let items = try! viewContext.fetch(fetchRequest)
        for item in items {
            viewContext.delete(item)
        }
        do {
            try viewContext.save()
            return true
        } catch {
            return false
        }
    }

    func saveOrUpdate(item: TodoItem) {
        if  updateTodo(with: item) {
        } else {
            addTodo(item)
        }
    }

    func clearTable() {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest:
                                                        NSFetchRequest<NSFetchRequestResult>(entityName: Constants.entityName))
        do {
            try viewContext.execute(batchDeleteRequest)
        } catch {
            print(error)
        }
    }
}
