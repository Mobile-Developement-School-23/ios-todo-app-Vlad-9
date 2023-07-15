import Foundation
import TodoItem

let defaults = UserDefaults.standard

enum Constants {
    static let separatorCSV = ";"
    static let newlineCSV = "\n"
    static let specialSymbolForCSV = "\u{1}"
    static let dbType: dbType = .coreData
}

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

enum dbType {
    case coreData
    case SQLite
}

// MARK: - FileCache

class FileCache: IFileCache {
    
    // MARK: - Dependencies
    
    var dbController: TodoLocalDBProtocol?
    private(set) var todoItems: [TodoItem] = []
    var isDirty = defaults.bool(forKey: "isDirty")
    
    // MARK: - Init
    
    init() {
        switch Constants.dbType {
        case .coreData:
            self.dbController = TodoCoreData.shared
        case .SQLite:
            self.dbController = TodoDB.instance
        }
    }
    
    private func getPath(with fileName: String, with format: AvaliableFormats) throws -> URL {

        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheErrors.pathError
        }
        return path.appendingPathComponent(fileName).appendingPathExtension(format.rawValue)
    }
    
    func getAll() -> [TodoItem] {
        return todoItems.reversed()
    }

    func setAll(items: [TodoItem], fromDB: Bool) {
        if fromDB {
            self.todoItems = (dbController?.getAllTodoItems())!//TodoDB.instance.getAllTodoItems()
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
}

// MARK: - Working with DB

extension FileCache {

    func clearLocalDB() {
        dbController?.clearTable()
    }

    func itemToDB(_ action: saveType, item: TodoItem) {
            switch action {
            case .update:
                dbController?.updateTodo(with: item)
            case .add:
                dbController?.addTodo(item)
            case .delete:
                dbController?.deleteTodo(id: item.id)
            case .upsert:
                dbController?.saveOrUpdate(item: item)
            }
    }
}
