import XCTest
@testable import Yandex_Homework_1

final class Yandex_Homework_1Tests: XCTestCase {

    var todoItemWithoutAllParameters: TodoItem!
    var todoItemWithParameters: TodoItem!
    var todoItemWithIncorrectDelimeter: TodoItem!
    var todoCollection: FileCache!
    var todoCollection2: FileCache!

    override func setUpWithError() throws {

        todoCollection = FileCache()
        todoCollection2 = FileCache()

        todoItemWithIncorrectDelimeter = TodoItem(id: TestTodoItemConstants.id2,
                                                  text: TestTodoItemConstants.textWithDelimeter,
                            priority: TestTodoItemConstants.priority,
                            dateCreated: TestTodoItemConstants.date)

        todoItemWithoutAllParameters = TodoItem(id: TestTodoItemConstants.id2,
            text: TestTodoItemConstants.text,
                            priority: TestTodoItemConstants.priority,
                            dateCreated: TestTodoItemConstants.date)

        todoItemWithParameters = TodoItem(id: TestTodoItemConstants.id,
                                          text: TestTodoItemConstants.text,
                                          deadline: TestTodoItemConstants.deadline,
                                          isDone: TestTodoItemConstants.isDone,
                                          priority: TestTodoItemConstants.priority,
                                          dateCreated: TestTodoItemConstants.date,
                                          dateChanged: TestTodoItemConstants.datUpdated)

    }

    override func tearDownWithError() throws {
    }

    // MARK: - Creating TodoItem Tests

    func testCreateTodoItemWithoutAllParameters() throws {
        XCTAssertNotNil(todoItemWithoutAllParameters.id)
        XCTAssertEqual(todoItemWithoutAllParameters.text, TestTodoItemConstants.text)
        XCTAssertEqual(todoItemWithoutAllParameters.priority, TestTodoItemConstants.priority)
        XCTAssertEqual(todoItemWithoutAllParameters.isDone, TestTodoItemConstants.isDone)
        XCTAssertNil(todoItemWithoutAllParameters.deadline)
        XCTAssertNil(todoItemWithoutAllParameters.dateChanged)
    }

    func testCreateTodoItemWithAllParameters() throws {

        XCTAssertEqual(todoItemWithParameters.text, TestTodoItemConstants.text)
        XCTAssertEqual(todoItemWithParameters.id, TestTodoItemConstants.id)
        XCTAssertEqual(todoItemWithParameters.deadline, TestTodoItemConstants.deadline)
        XCTAssertEqual(todoItemWithParameters.dateChanged, TestTodoItemConstants.datUpdated)
        XCTAssertEqual(todoItemWithParameters.dateCreated, TestTodoItemConstants.date)
        XCTAssertEqual(todoItemWithParameters.priority, TestTodoItemConstants.priority)
        XCTAssertEqual(todoItemWithParameters.isDone, TestTodoItemConstants.isDone)

    }

    // MARK: - FileCache add Tests

    func testFileCacheAddItem() throws {
        let result = todoCollection.add(todoItem: todoItemWithoutAllParameters)
        XCTAssertEqual(todoCollection.todoItems.first, todoItemWithoutAllParameters)
        XCTAssertEqual(result, todoItemWithoutAllParameters)
    }
    func testFileCacheAddSeveralTodosWithSameID() throws {
        todoCollection.add(todoItem: todoItemWithoutAllParameters)
        todoCollection.add(todoItem: todoItemWithoutAllParameters)
        XCTAssertEqual(todoCollection.todoItems.count, 1)
    }

    func testFileCacheAddSeveralTodosWithDifferentID() throws {
        todoCollection.add(todoItem: todoItemWithoutAllParameters)
        todoCollection.add(todoItem: todoItemWithParameters)
        XCTAssertEqual(todoCollection.todoItems.count, 2)
    }

    // MARK: - FileCache remove Tests

    func testFileCacheRemoveElementFromCollectionByCorrectID() throws {
        todoCollection.add(todoItem: todoItemWithoutAllParameters)
        todoCollection.removeTodoItem(by: todoItemWithoutAllParameters.id)
        XCTAssertEqual(todoCollection.todoItems.count, 0)
    }

    func testFileCacheRemoveElementFromCollectionWithSeveralElementsByCorrectID() throws {
        todoCollection.add(todoItem: todoItemWithParameters)
        todoCollection.add(todoItem: todoItemWithoutAllParameters)
        todoCollection.removeTodoItem(by: todoItemWithParameters.id)

        XCTAssertEqual(todoCollection.todoItems.count, 1)
        XCTAssertEqual(todoCollection.todoItems.first, todoItemWithoutAllParameters)
    }

    func testFileCacheRemoveElementFromiCollectionByWrongID() throws {
        todoCollection.add(todoItem: todoItemWithoutAllParameters)
        var result = todoCollection.removeTodoItem(by: TestTodoItemConstants.id)

        XCTAssertEqual(todoCollection.todoItems.count, 1)
        XCTAssertEqual(todoCollection.todoItems.first, todoItemWithoutAllParameters)
        XCTAssertNil(result)
    }

    // MARK: - CSV TodoItems Tests

    func testCorrectConvertItemWithoutAllParametersToCSV() throws {
        XCTAssertEqual(todoItemWithoutAllParameters.csv as! String, TestCSVConstants.testCSVWithoutAllParameters)
    }
    func testCorrectConvertItemWithAllParametersToCSV() throws {
        XCTAssertEqual(todoItemWithParameters.csv as! String, TestCSVConstants.testCSVWithAllParameters)
    }

    func testCSVParseWithoutAllParameters() throws {
        let newTodoItem = TodoItem.parse(csv: TestCSVConstants.testCSVWithoutAllParameters)
        XCTAssertEqual(todoItemWithoutAllParameters, newTodoItem)
    }

    func testCSVParseWithAllParameters() throws {
        let newTodoItem = TodoItem.parse(csv: TestCSVConstants.testCSVWithAllParameters)
        XCTAssertEqual(todoItemWithParameters, newTodoItem)
    }

    // MARK: - CSV FileCache Tests

    func testTodoCollectionSaveAndLoadCSVWithDelimeterInText() throws {
        todoCollection.add(todoItem: todoItemWithIncorrectDelimeter)
        try todoCollection.saveTodoItems(to: TestCSVConstants.testCSVFileName, with: .csv)
        try todoCollection2.loadTodoItems(from: TestCSVConstants.testCSVFileName, with: .csv)
        XCTAssertEqual(todoCollection.todoItems, todoCollection2.todoItems)
    }

    func testTodoCollectionSaveAndLoadCSVWithoutAllParameters() throws {
        todoCollection.add(todoItem: todoItemWithoutAllParameters)
        try todoCollection.saveTodoItems(to: TestCSVConstants.testCSVFileName, with: .csv)
        try todoCollection2.loadTodoItems(from: TestCSVConstants.testCSVFileName, with: .csv)
        XCTAssertEqual(todoCollection.todoItems, todoCollection2.todoItems)
    }

    func testTodoCollectionSaveAndLoadCSVWithAllParameters() throws {
        todoCollection.add(todoItem: todoItemWithParameters)
        try todoCollection.saveTodoItems(to: TestCSVConstants.testCSVFileName, with: .csv)
        try todoCollection2.loadTodoItems(from: TestCSVConstants.testCSVFileName, with: .csv)
        XCTAssertEqual(todoCollection.todoItems, todoCollection2.todoItems)
    }

    func testTodoCollectionSaveAndLoadCSVWithSeveralTodoLists() throws {
        todoCollection.add(todoItem: todoItemWithoutAllParameters)
        todoCollection.add(todoItem: todoItemWithParameters)
        try todoCollection.saveTodoItems(to: TestCSVConstants.testCSVFileName, with: .csv)
        try todoCollection2.loadTodoItems(from: TestCSVConstants.testCSVFileName, with: .csv)
        XCTAssertEqual(todoCollection.todoItems, todoCollection2.todoItems)
    }

    func testSaveSeveralCollectionsCSVInOneFile() throws {
        todoCollection.add(todoItem: todoItemWithoutAllParameters)
        todoCollection2.add(todoItem: todoItemWithParameters)
        try todoCollection.saveTodoItems(to: TestCSVConstants.testCSVFileName, with: .csv)
        try todoCollection2.saveTodoItems(to: TestCSVConstants.testCSVFileName, with: .csv)
        let todoCollection3 = FileCache()
        try todoCollection3.loadTodoItems(from: TestCSVConstants.testCSVFileName, with: .csv)

        XCTAssertEqual(todoCollection3.todoItems, todoCollection2.todoItems)
        XCTAssertNotEqual(todoCollection3.todoItems, todoCollection.todoItems)
    }

    // MARK: - JSON TodoItems Tests

    func testCorrectConvertItemWithoutAllParametersToJSONDict() throws {
        XCTAssertTrue(NSDictionary(dictionary: todoItemWithoutAllParameters.json as! [String: Any])
            .isEqual(to: TestJSONConstants.jsonDictWithoutAllParameters))
    }

    func testCorrectConvertItemWithAllParametersToJSONDict() throws {
        XCTAssertTrue(NSDictionary(dictionary: todoItemWithParameters.json as! [String: Any])
            .isEqual(to: TestJSONConstants.jsonDictWithAllParameters))
    }

    func testJSONParseWithoutAllParameters() throws {
        let newTodoItem = TodoItem.parse(json: TestJSONConstants.jsonDictWithoutAllParameters)
        XCTAssertEqual(todoItemWithoutAllParameters, newTodoItem)
    }

    func testJSONParseWithAllParameters() throws {
        let newTodoItem = TodoItem.parse(json: TestJSONConstants.jsonDictWithAllParameters)
        XCTAssertEqual(todoItemWithParameters, newTodoItem)
    }

    // MARK: - JSON FileCache Tests

    func testSaveSeveralCollectionsJSONInOneFile() throws {
        todoCollection.add(todoItem: todoItemWithoutAllParameters)
        todoCollection2.add(todoItem: todoItemWithParameters)
        try todoCollection.saveTodoItems(to: TestJSONConstants.testJSONFileName, with: .json)
        try todoCollection2.saveTodoItems(to: TestJSONConstants.testJSONFileName, with: .json)
        let todoCollection3 = FileCache()
        try todoCollection3.loadTodoItems(from: TestJSONConstants.testJSONFileName, with: .json)
        XCTAssertEqual(todoCollection3.todoItems, todoCollection2.todoItems)
        XCTAssertNotEqual(todoCollection3.todoItems, todoCollection.todoItems)
    }

    func testTodoCollectionJSONSaveAndLoadWithoutAllParameters() throws {
        todoCollection.add(todoItem: todoItemWithoutAllParameters)
        try todoCollection.saveTodoItems(to: TestJSONConstants.testJSONFileName, with: .json)
        try todoCollection2.loadTodoItems(from: TestJSONConstants.testJSONFileName, with: .json)
        XCTAssertEqual(todoCollection.todoItems, todoCollection2.todoItems)
    }

    func testTodoCollectionJSONSaveAndLoadWithAllParameters() throws {
        todoCollection.add(todoItem: todoItemWithParameters)
        try todoCollection.saveTodoItems(to: TestJSONConstants.testJSONFileName, with: .json)
        try todoCollection2.loadTodoItems(from: TestJSONConstants.testJSONFileName, with: .json)
        XCTAssertEqual(todoCollection.todoItems, todoCollection2.todoItems)
    }

    func testTodoCollectionJSONSaveAndLoadWithSeveralTodoLists() throws {
        todoCollection.add(todoItem: todoItemWithoutAllParameters)
        todoCollection.add(todoItem: todoItemWithParameters)
        try todoCollection.saveTodoItems(to: TestJSONConstants.testJSONFileName, with: .json)
        try todoCollection2.loadTodoItems(from: TestJSONConstants.testJSONFileName, with: .json)
        XCTAssertEqual(todoCollection.todoItems, todoCollection2.todoItems)
    }

    func testPerformanceExample() throws {
        self.measure {
        }
    }
}
