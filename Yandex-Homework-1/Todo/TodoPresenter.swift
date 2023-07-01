import Foundation
import CocoaLumberjack
import TodoItem


protocol ITodoPresenterDelegate: AnyObject {
    func saveTodo(item: TodoItem)
    func removeTodo(item: TodoItem)
}
final class TodoPresenter {
    
    weak var delegate: ITodoPresenterDelegate?
    var viewModel: TodoViewModel?
    var todoItem: TodoItem?

    func createViewModel(todoItem: TodoItem) -> TodoViewModel{
        return TodoViewModel(id: todoItem.id,
                             text: todoItem.text,
                             deadline: todoItem.deadline,
                             isDone: todoItem.isDone,
                             hexCode: todoItem.hexCode,
                             priority: todoItem.priority,
                             dateCreated: todoItem.dateCreated,
                             dateChanged: todoItem.dateChanged)
    }

    func initialize(todoItem: TodoItem?) {
        self.todoItem = todoItem
        if todoItem != nil {
            self.viewModel = createViewModel(todoItem: todoItem!)
        }
    }

    weak var view: ViewController?
    func viewDidLoad() {
        if todoItem != nil {
            view?.setupWithViewModel(model: viewModel!)
        } else {
            view?.setupWithNewModel()
        }
    }
}

extension TodoPresenter: IViewControllerDelegate {
    func remove(with: TodoViewModel) {
        self.todoItem = TodoItem(id: with.id, text: with.text, deadline: with.deadline, isDone: with.isDone,hexCode: with.hexCode, priority: with.priority, dateCreated: with.dateCreated, dateChanged: with.dateChanged)
        if let todoItem {
            delegate?.removeTodo(item: todoItem).self
        }
    }
    
    func save(with: TodoViewModel) {
        self.todoItem = TodoItem(id: with.id, text: with.text, deadline: with.deadline, isDone: with.isDone,hexCode: with.hexCode, priority: with.priority, dateCreated: with.dateCreated, dateChanged: with.dateChanged)
        if let todoItem {
            delegate?.saveTodo(item: todoItem).self
        }
    }
}
