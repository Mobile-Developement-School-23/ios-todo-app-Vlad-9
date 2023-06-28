import UIKit

class MainViewController: UIViewController {
    
    private  var backButton =  UIButton(type: .system)
    private  var emptyButton =  UIButton(type: .system)
    private var assembler = TodoAssembly()
    private var todoItems:FileCache = FileCache()
    
    func setupbutton() {
        backButton.setTitle(NSLocalizedString("task.goToTask", comment: "low go to task"), for: .normal)
        backButton.addTarget(self, action: #selector(presentView), for: .touchUpInside)
        emptyButton.setTitle(NSLocalizedString("task.newTask", comment: "create new task"), for: .normal)
        emptyButton.addTarget(self, action: #selector(presentViewWithNewTask), for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.assembler.setdelegate(item: self)
        self.view.backgroundColor = Colors.backPrimary.value
        setupLayout()
        self.navigationController?.present(UINavigationController(rootViewController: assembler.createTodoViewController(with: loadItems())), animated: true)
    }
    
    private func setupLayout() {
        setupbutton()
        view.addSubview(backButton)
        view.addSubview(emptyButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        emptyButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyButton.topAnchor.constraint(equalTo: backButton.bottomAnchor,constant: 10)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func loadItems() -> TodoItem {
        var todoModel = TodoItem(text: "", priority: .normal)
        do {
            try todoItems.loadTodoItems(from: "SavedJsonItems", with: .json)
            return todoItems.todoItems.last ?? todoModel
        } catch {
            return todoModel
        }
    }
}

//MARK: - ITodoPresenterDelegate

extension MainViewController: ITodoPresenterDelegate {
    func saveTodo(item: TodoItem) {
        todoItems.add(todoItem: item)
        do {
            try todoItems.saveTodoItems(to: "SavedJsonItems", with: .json)
        } catch {
        }
    }
    func removeTodo(item: TodoItem) {
        do {
            todoItems.removeTodoItem(by: item.id)
            try todoItems.saveTodoItems(to: "SavedJsonItems", with: .json)
        } catch {
        }
    }
}

//MARK: - Button handlers

extension MainViewController {
    @objc func presentViewWithNewTask() {
        self.navigationController?.present(UINavigationController(rootViewController: assembler.createTodoViewController(with: nil)), animated: true)
    }
    @objc func presentView() {
        let model = todoItems.todoItems.last
        self.navigationController?.present(UINavigationController(rootViewController: assembler.createTodoViewController(with: loadItems())), animated: true)
    }
}
