import UIKit
import TodoItem

protocol ITodoAssembly {
    func createTodoViewController(with model: TodoItem?) -> UIViewController
    func setdelegate(item: ITodoPresenterDelegate)
}

class TodoAssembly: ITodoAssembly {
    let presenter = TodoPresenter()
    func setdelegate(item:ITodoPresenterDelegate) {
        presenter.delegate = item
    }

    func createTodoViewController(with model: TodoItem?) -> UIViewController {

        if let model {
            presenter.initialize(todoItem: model)
        } else {
            presenter.initialize(todoItem: TodoItem(text: "", priority: .basic, updatedID: UIDevice.current.identifierForVendor!.uuidString))
        }
        let view = ViewController(presenter: presenter)
        presenter.view = view
        let navController = UINavigationController()
        navController.viewControllers = [view]
        return view
    }
}
