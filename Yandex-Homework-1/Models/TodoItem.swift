//import Foundation
//
//// MARK: - TodoItem Constants
//
//
//// MARK: - TodoItem ext. for Equatable
//
//extension TodoItem {
//    static  func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
//        return lhs.id == rhs.id
//    }
//}
//
//// MARK: - TodoItem
//
//struct TodoItem: Equatable {
//    
//    enum Constants {
//        static let separatorCSV = ";"
//        static let newlineCSV = "\n"
//        static let specialSymbolForCSV = "\u{1}"
//    }
//
//    // MARK: - Keys enum
//
//    enum Keys: Int, CaseIterable {
//
//        case keyId = 0
//        case keyText
//        case keyDeadline
//        case keyIsDone
//        case hexCode
//        case keyPriority
//        case keyDateCreated
//        case keyDateChanged
//
//        var description: String {
//            switch self {
//            case .keyId:
//                return "id"
//            case .keyText:
//                return "text"
//            case .keyDeadline:
//                return "deadline"
//            case .keyIsDone:
//                return "isDone"
//            case .hexCode:
//                return "hexCode"
//            case .keyPriority:
//                return "priority"
//            case .keyDateCreated:
//                return "dateCreated"
//            case .keyDateChanged:
//                return "dateChanged"
//            }
//        }
//    }
//
//    // MARK: - Priority enum
//
//    enum Priority: Int {
//        case low
//        case normal
//        case high
//    }
//
//    // MARK: - Properties
//
//    public let id: String
//    public let text: String
//    public let deadline: Date?
//    public var isDone: Bool
//    public let hexCode: String?
//    public let priority: Priority
//    public let dateCreated: Date
//    public let dateChanged: Date?
//
//    // MARK: - Initializer
//
//    init(
//        id: String = UUID().uuidString,
//        text: String,
//        deadline: Date? = nil,
//        isDone: Bool = false,
//        hexCode: String? = nil,
//        priority: Priority,
//        dateCreated: Date = Date(),
//        dateChanged: Date? = nil
//    ) {
//        self.id = id
//        self.text = text
//        self.deadline = deadline
//        self.isDone = isDone
//        self.hexCode = hexCode
//        self.priority = priority
//        self.dateCreated = dateCreated
//        self.dateChanged = dateChanged
//    }
// 
//    mutating func setDone(flag: Bool){
//          self.isDone = flag
//      }
//}
//
//// MARK: - TodoItem Extenison
//
//extension TodoItem {
//
//    // MARK: - CSV
//
//    var csv: Any {
//
//        var result: String =
//        "\(id)\(Constants.separatorCSV)\(text.replacingOccurrences(of: Constants.separatorCSV, with: Constants.specialSymbolForCSV))"
//        result += Constants.separatorCSV
//        if deadline != nil {
//            result += String(Int(dateCreated.timeIntervalSince1970))
//        }
//
//        result += Constants.separatorCSV + String(isDone)
//        result += Constants.separatorCSV
//        if hexCode != nil {
//            result += Constants.separatorCSV + "\(hexCode)"
//           
//        }
//        result += Constants.separatorCSV
//        
//        if priority != .normal {
//            result += String(priority.rawValue)
//        }
//
//        result += Constants.separatorCSV + String(Int(dateCreated.timeIntervalSince1970))
//        result += Constants.separatorCSV
//        if dateChanged != nil {
//            result += String(Int(dateCreated.timeIntervalSince1970))
//        }
//        return result
//    }
//
//    // MARK: - CSV parsing
//
//    static func parse(csv: Any) -> TodoItem? {
//
//        guard let object = csv as? String else {
//            return nil
//        }
//
//        let columns = object.components(separatedBy: Constants.separatorCSV)
//            .map({$0.replacingOccurrences(of: Constants.specialSymbolForCSV,
//                                          with: Constants.separatorCSV)})
//
//        let id = columns[Keys.keyId.rawValue]
//        let text = columns[Keys.keyText.rawValue]
//
//        guard let dateCreated = TimeInterval(columns[Keys.keyDateCreated.rawValue])
//            .flatMap({ Date(timeIntervalSince1970: $0) }),
//              let isDone = Bool(columns[Keys.keyIsDone.rawValue])
//        else {
//            return nil
//        }
//        let hexCode = columns[Keys.hexCode.rawValue]
//        let dateUpdated = TimeInterval(columns[Keys.keyDateChanged.rawValue])
//            .flatMap { Date(timeIntervalSince1970: $0) }
//        let deadline  = TimeInterval(columns[Keys.keyDeadline.rawValue])
//            .flatMap { Date(timeIntervalSince1970: $0) }
//        let priority = Int(columns[Keys.keyPriority.rawValue])
//            .flatMap(Priority.init(rawValue:)) ?? .normal
//
//        return TodoItem(
//            id: id,
//            text: text,
//            deadline: deadline,
//            isDone: isDone,
//            hexCode: hexCode,
//            priority: priority,
//            dateCreated: dateCreated,
//            dateChanged: dateUpdated
//        )
//    }
//
//    // MARK: - JSON
//
//    var json: Any {
//
//        var result: [String: Any] = [
//            Keys.keyId.description: id,
//            Keys.keyText.description: text,
//            Keys.keyIsDone.description: isDone,
//            Keys.keyDateCreated.description: Int(dateCreated.timeIntervalSince1970)
//        ]
//        if let hexCode {
//            result[Keys.hexCode.description] = hexCode
//        }
//        if let deadline {
//            result[Keys.keyDeadline.description] = Int(deadline.timeIntervalSince1970)
//        }
//
//        if priority != .normal {
//            result[Keys.keyPriority.description] = priority.rawValue
//        }
//
//        if let dateChanged {
//            result[Keys.keyDateChanged.description] = Int(dateChanged.timeIntervalSince1970)
//        }
//        return result
//    }
//
//    // MARK: - JSON parsing
//
//    static func parse(json: Any) -> TodoItem? {
//
//        guard let object = json as? [String: Any] else {
//            return nil
//        }
//        guard
//            let id = object[Keys.keyId.description] as? String,
//            let text = object[Keys.keyText.description] as? String,
//            let dateCreated = (object[Keys.keyDateCreated.description] as? TimeInterval)
//                .flatMap({ Date(timeIntervalSince1970: $0) }),
//            let isDone = object[Keys.keyIsDone.description] as? Bool
//
//        else {
//            return nil
//        }
//        let hexCode = object[Keys.hexCode.description] as? String
//        let dateUpdated = (object[Keys.keyDateChanged.description] as? TimeInterval)
//            .flatMap { Date(timeIntervalSince1970: $0) }
//        let deadline  = (object[Keys.keyDeadline.description] as? TimeInterval)
//            .flatMap { Date(timeIntervalSince1970: $0) }
//        let priority = (object[Keys.keyPriority.description] as? Int)
//            .flatMap(Priority.init(rawValue:)) ?? .normal
//
//        return TodoItem(
//            id: id,
//            text: text,
//            deadline: deadline,
//            isDone: isDone,
//            hexCode: hexCode,
//            priority: priority,
//            dateCreated: dateCreated,
//            dateChanged: dateUpdated
//        )
//    }
//}
