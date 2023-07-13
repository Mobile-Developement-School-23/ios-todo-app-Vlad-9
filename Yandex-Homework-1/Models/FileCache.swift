import Foundation
import TodoItem
let defaults = UserDefaults.standard
enum Constants {
    static let separatorCSV = ";"
    static let newlineCSV = "\n"
    static let specialSymbolForCSV = "\u{1}"
}

//

// MARK: - FileCache protocol

protocol IFileCache {
    var todoItems: [TodoItem] { get }
    var isDirty: Bool { set get }
    func add(todoItem: TodoItem) -> TodoItem?
    func removeTodoItem(by id: String) -> TodoItem?
    func saveTodoItems(to fileName: String, with format: AvaliableFormats) throws
    func loadTodoItems(from fileName: String, with format: AvaliableFormats) throws
}

// MARK: - FileCacheErrors

enum FileCacheErrors: Error {
    case parsingJSONError
    case pathError
}

// MARK: - AvaliableFormats

enum AvaliableFormats: String {
    case json
    case csv
}
enum saveType {
    case update
    case add
    case upsert
    case delete
}

// MARK: - FileCache

class FileCache: IFileCache {

    private(set) var todoItems: [TodoItem] = []
    var isDirty = defaults.bool(forKey: "isDirty")
    private func getPath(with fileName: String, with format: AvaliableFormats) throws -> URL {

        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.pathError
        }
        return path.appendingPathComponent(fileName).appendingPathExtension(format.rawValue)
    }
    func getAll() -> [TodoItem] {
        return todoItems.reversed()
    }
    func clearLocalDB() {
        TodoDB.instance.clearTable()
    }
    func setAll(items: [TodoItem], fromDB: Bool) {
        if fromDB {
            self.todoItems = TodoDB.instance.getAllTodoItems()
        } else {
            self.todoItems = items
        }
    }
    
    @discardableResult
    func add(todoItem: TodoItem) -> TodoItem? {
        if let index = todoItems.firstIndex(where: { $0.id == todoItem.id}) {
            var newItem = todoItem
            newItem.setDate(date: Date())
            todoItems[index] = newItem
        } else {
            todoItems.append(todoItem)
        }
        return todoItem
    }

    func removeTodoItem(by id: String) -> TodoItem? {
        if let index = todoItems.firstIndex(where: { $0.id == id}) {
            return todoItems.remove(at: index)
        }
        return nil
    }
    func removeAll() {
        self.todoItems = []
    }
    func saveTodoItems(to fileName: String, with format: AvaliableFormats) throws {
       //TodoDB.instance.addContact(cname: "12d13", cphone: "1111", caddress: "aksdd")
        let path = try getPath(with: fileName, with: format)
        var savedData = Data()
        switch format {

        case .json:
            let todoItemsDictionary = todoItems.map { (($0.json) as? [String: Any]) }
            savedData = try JSONSerialization.data(withJSONObject: todoItemsDictionary)

        case .csv:
            let result = todoItems.map { String(describing: ($0.csv)) as String }
            var resultstring = TodoItem.Keys.allCases.map {$0.description}
                .joined(separator: Constants.separatorCSV)
            resultstring += Constants.newlineCSV +  result.joined(separator: Constants.newlineCSV)
            savedData = Data(resultstring.utf8)

        }
        try savedData.write(to: path)
    }

    func loadTodoItems(from fileName: String, with format: AvaliableFormats) throws {
        let path = try getPath(with: fileName, with: format)

        switch format {

        case .json:
             let savedData = try Data(contentsOf: path)
        guard let jsonArray = try JSONSerialization.jsonObject(with: savedData) as? [[String: Any]] else {
                throw FileCacheErrors.parsingJSONError
            }
            self.todoItems = jsonArray.compactMap { TodoItem.parse(json: $0) }
        case .csv:
            let savedData = try String(contentsOf: path)
            let rowsCSV = savedData.components(separatedBy: Constants.newlineCSV).dropFirst()
            self.todoItems = rowsCSV.compactMap { TodoItem.parse(csv: $0) }
        }
    }
    func itemToDB(_ action: saveType,item: TodoItem) {
      
        do {
           // TodoDB.instance.saveAll(items: getAllItems())
           // try todoItems.saveTodoItems(to: Constants.fileCacheName, with: .json)
            switch action {
            case .update:
                TodoDB.instance.updateTodo(item: item)
            case .add:
                TodoDB.instance.addTodo(item: item)
            case .delete:
                TodoDB.instance.deleteTodo(id: item.id)
            case .upsert:
                TodoDB.instance.saveOrUpdate(item: item)
            }
        } catch {
            print (error,"Can't save to file")
        }
//        DispatchQueue.main.async {
//            self.view?.reloadTable()
//        }
    
}
}
