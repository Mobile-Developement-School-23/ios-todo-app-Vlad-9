@testable import Yandex_Homework_1
import Foundation

enum TestJSONConstants {
    static let jsonDictWithoutAllParameters: [String: Any] = [
        "id": TestTodoItemConstants.id2,
        "text": TestTodoItemConstants.text,
        "priority": 0,
        "isDone": TestTodoItemConstants.isDone,
        "dateCreated": 1681469040.0
    ]
    static let testJSONFileName = "TestCSV3"
    static let jsonDictWithAllParameters: [String: Any] = [
        "priority": 0,
        "isDone": TestTodoItemConstants.isDone,
        "id": TestTodoItemConstants.id,
        "dateChanged": 1681555440.0,
        "deadline": 1681728240.0,
        "text": TestTodoItemConstants.text,
        "dateCreated": 1681469040.0
    ]
}

enum TestCSVConstants {

    static let testCSVFileName = "TestCSV3"
    static let testCSVWithAllParameters = """
    12345;Test;1681469040;false;0;1681469040;1681469040
    """
    static let testCSVWithoutAllParameters =  """
    2B76FE70-ADC8-43BA-A586-17B7D7D66351;Test;;false;0;1681469040;
    """

}

enum TestTodoItemConstants {

    static let id = "12345"
    static let id2 = "2B76FE70-ADC8-43BA-A586-17B7D7D66351"

    static let text = "Test"
    static let textWithDelimeter = "Te;us;kkt"
    static let priority = TodoItem.Priority.low
    static let isDone = false

    static var date: Date {
        let isoDate = "2023-04-14T10:44:00+0000"
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from:isoDate)!
    }
    static let datUpdated = Calendar.current.date(byAdding: .day, value: 1, to: date)
    static let deadline = Calendar.current.date(byAdding: .day, value: 3, to: date)
}
