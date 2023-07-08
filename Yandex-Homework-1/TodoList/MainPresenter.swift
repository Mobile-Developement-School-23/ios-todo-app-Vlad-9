import Foundation
import CocoaLumberjack
import TodoItem

//MARK: - Constants

extension MainPresenter {
    enum Constants {
        static let dirtyKey = "isDirty"
        static let fileCacheName = "SavedJsonItems"
        static let unsynchronizedErrorCode = "unsynchronized data"
        static let duplicateErrorCode = "duplicate item"
        static let maxRetryCount = 5
        static let secondInNanoSeconds:Double = 1_000_000_000
    }
}

final class MainPresenter {
    
    //MARK: - Dependencies
    
    private var assembler = TodoAssembly()
    var networkService = NetworkService()
    private var todoItems:FileCache = FileCache()
    weak var view: MainViewController?
    
    private var retryCount = 0
    private let maxRetryCount = 5
    private var fetchRequestStart = false
    private let minDelay: Double = 2
    private let maxDelay: Double = 120
    private let factor: Double = 1.5
    private let jitter: Double = 0.05
    private var currentDelay: Double = 2
    //MARK: - Init
    
    func initialize() {
    }
    
    //MARK: - ViewDidLoad
    func viewDidLoad()  {
        view?.updateActivityIndicator(isAnimating: true)
        assembler.setdelegate(item: self)
        Task {
            await view?.configure()
            try await syncWithServer()
            await view?.setSectionViewCount(with:  todoItems.getAll().filter({$0.isDone == true}).count)
            await view?.updateActivityIndicator(isAnimating: false)
        }
    }
}

//MARK: - Public

extension MainPresenter {
    
    func getAllItemsCount() -> Int{
        return todoItems.todoItems.count
    }
    func getAllItems() -> [TodoItem]{
        return todoItems.getAll()
    }
    func addItem(item: TodoItem) {
        self.todoItems.add(todoItem: item)
    }
    func assemblyWith(item: TodoItem) -> UIViewController {
        assembler.createTodoViewController(with: item)
    }
    
    @objc func presentViewWithNewTask() {
        var newVc = UINavigationController(rootViewController: assembler.createTodoViewController(with: nil))
        newVc.transitioningDelegate = self.view
        self.view?.navigationController?.present(newVc, animated: true)
    }
    
    func presentViewWith(id: String) {
        let newItem =  todoItems.getAll().first(where: {$0.id == id})
        var newVc = UINavigationController(rootViewController: assembler.createTodoViewController(with: newItem))
        newVc.transitioningDelegate = self.view
        self.view?.navigationController?.present(newVc, animated: true)
    }
    func updateDone(item:TodoItem) {
        self.updateDoneToNetworkService(item: item,retryCount: 0, delay: minDelay)
    }
}

//MARK: - Private

private extension MainPresenter {
    
    private func syncWithServer() async throws {
        do {
            if defaults.bool(forKey: Constants.dirtyKey) {
                try self.todoItems.loadTodoItems(from: Constants.fileCacheName, with: .json)
                await syncIfDirty()
            }
            let newItems = try await loadItems()
            todoItems.removeAll()
            for item in newItems {
                todoItems.add(todoItem: item)
            }
        } catch {
            print(error)
        }
    }
    
    private func makeToDoItems(from models: [Todomodel]) -> [TodoItem] {
        var items: [TodoItem] = []
        for model in models {
            items.append(TodoItem(fromDTO: model))
        }
        return items
    }
    
    private func loadItems() async throws -> [TodoItem]  {
        do {
            let toDoModels = try await networkService.getList()
            return makeToDoItems(from: toDoModels)
            
        } catch {
            print(error,".Try to load from local file")
            do {
                return  try loadFromFile()
            }
            catch {
                print(error,".Can't load from file")
            }
        }
        return []
    }
    private func syncIfDirty() async {
        
        if defaults.bool(forKey: Constants.dirtyKey) {
            do {
                let newItems = try await updateList(items: makeTodoModelList(items: todoItems.todoItems))
                
                todoItems.removeAll()
                for item in newItems {
                    todoItems.add(todoItem: item)
                }
                defaults.set(false, forKey:  Constants.dirtyKey)
            } catch {
            }
        }
    }

    private func removeFromNetworkService(item: TodoItem, retryCount: Int, delay: Double) {
        Task {
            do {
                await syncIfDirty()
                await view?.updateActivityIndicator(isAnimating: true)
                try await networkService.removeElement(by:  Todomodel(item: item).id)
            } catch URLErrors.errorCode(Constants.unsynchronizedErrorCode) {
                try await syncWithServer()
                todoItems.removeTodoItem(by: item.id)
                removeFromNetworkService(item: item, retryCount: retryCount, delay: delay)
            } catch URLErrors.noFound {
                print(URLErrors.noFound, "Can't find element")
            }
            catch {
                if retryCount <= Constants.maxRetryCount {
                    try await Task.sleep(nanoseconds: UInt64(delay*Constants.secondInNanoSeconds))
                    removeFromNetworkService(item: item, retryCount: retryCount + 1, delay: getNextDelay(currentDelay: delay))
                } else {
                    print(error, "Cant't save to server. Trying save to file")
                    self.saveAll(withError: true)
                }
            }
            DispatchQueue.main.async {
                self.view?.updateActivityIndicator(isAnimating: false)
                self.view?.reloadTable()
                self.saveAll(withError: false)
            }
        }
    }

    private func updateItemWithNetworkService(item: Todomodel) async {
        do {
            try await networkService.updateElement(elment: item)
        } catch {
            print(error, "Cant'update Element")
        }
        DispatchQueue.main.async {
            self.view?.reloadTable()
        }
    }
    
    private func updateDoneToNetworkService(item: TodoItem, retryCount: Int, delay: Double){
        Task {
            do {
                await syncIfDirty()
                await view?.updateActivityIndicator(isAnimating: true)
                try await networkService.updateElement(elment: Todomodel(item: item))
            }  catch URLErrors.errorCode(Constants.unsynchronizedErrorCode) {
                try await syncWithServer()
                var item2 = item
                item2.setDone(flag: item.isDone)
                todoItems.add(todoItem: item2)
                updateDone(item:  item2)
            } catch URLErrors.noFound {
                print(URLErrors.noFound, "Can't find element")
            } catch {
                if retryCount <= Constants.maxRetryCount {
                    try await Task.sleep(nanoseconds: UInt64(delay*Constants.secondInNanoSeconds))
                    updateDoneToNetworkService(item: item, retryCount: retryCount + 1, delay: getNextDelay(currentDelay: delay))
                } else {
                    print(error, "Cant't save to server. Trying save to file")
                    self.saveAll(withError: true)
                }
            
            }
            DispatchQueue.main.async {
                self.view?.setSectionViewCount(with:  self.todoItems.getAll().filter({$0.isDone == true}).count)
                self.view?.reloadTable()
                self.view?.updateActivityIndicator(isAnimating: false)
                self.saveAll(withError: false)
            }
        }
    }
    
    private func uploadItemToNetworkService(item: TodoItem, retryCount: Int, delay: Double) {
        Task {
            do {
                await syncIfDirty()
                await view?.updateActivityIndicator(isAnimating: true)
                try await networkService.uploadItem(item: Todomodel(item: item))
            } catch URLErrors.errorCode(Constants.unsynchronizedErrorCode) {
                try await syncWithServer()
                uploadItemToNetworkService(item: item,retryCount: retryCount,delay: delay)
            } catch URLErrors.errorCode(Constants.duplicateErrorCode) {
                var newItem = Todomodel(item: item)
                newItem.updateID()
                try await updateItemWithNetworkService(item: newItem)
            } catch {
                if retryCount <= Constants.maxRetryCount {
                    try await Task.sleep(nanoseconds: UInt64(delay*Constants.secondInNanoSeconds))
                    uploadItemToNetworkService(item: item, retryCount: retryCount + 1, delay: getNextDelay(currentDelay: delay))
                } else {
                    print(error, "Cant't save to server. Trying save to file")
                    self.saveAll(withError: true)
                }
            }
            DispatchQueue.main.async {
                self.view?.updateActivityIndicator(isAnimating: false)
                self.view?.reloadTable()
                self.saveAll(withError: false)
            }
        }
    }
    private func makeTodoModelList(items: [TodoItem]) -> [Todomodel] {
        var newArray: [Todomodel] = []
        for item in items {
            newArray.append(Todomodel(item: item))
        }
        return newArray
    }
    
    private func updateList(items: [Todomodel]) async throws -> [TodoItem] {
        let toDoModels = try await networkService.updateList(list: items )
        return makeToDoItems(from: toDoModels)
    }
    private func loadFromFile()throws -> [TodoItem]{
        
        try todoItems.loadTodoItems(from: Constants.fileCacheName, with: .json)
        return todoItems.todoItems
    }
    
    private func saveAll(withError: Bool) {
        do {
            if withError {
                defaults.set(true, forKey:Constants.dirtyKey)
            }
            try todoItems.saveTodoItems(to: Constants.fileCacheName, with: .json)
        } catch {
            print (error,"Can't save to file")
        }
        DispatchQueue.main.async {
            self.view?.reloadTable()
        }
    }
}

//MARK: - ITodoPresenterDelegate

extension MainPresenter: ITodoPresenterDelegate {
    func saveTodo(item: TodoItem) {
        todoItems.add(todoItem: item)
        uploadItemToNetworkService(item: item,retryCount: 0,delay: minDelay)
    }
    
    func removeTodo(item: TodoItem) {
        todoItems.removeTodoItem(by: item.id)
        removeFromNetworkService(item: item, retryCount: 0, delay: minDelay)
        view?.setSectionViewCount(with:  todoItems.getAll().filter({$0.isDone == true}).count)
        view?.reloadTable()
    }
}

//MARK: - Delay
extension MainPresenter {
    private func getNextDelay(currentDelay: Double) -> Double {
        let randomJitter = Double.random(in: 0...(jitter * currentDelay))
        return min(maxDelay, factor * currentDelay) + randomJitter
    }
}
