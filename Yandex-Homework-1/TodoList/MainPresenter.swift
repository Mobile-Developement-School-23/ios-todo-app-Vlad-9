import Foundation
import CocoaLumberjack
import TodoItem

// MARK: - Constants

extension MainPresenter {
    enum Constants {
        static let dirtyKey = "isDirty"
        static let fileCacheName = "SavedJsonItems"
        static let unsynchronizedErrorCode = "unsynchronized data"
        static let duplicateErrorCode = "duplicate item"
        static let maxRetryCount = 5
        static let secondInNanoSeconds: Double = 1_000_000_000
    }
}

final class MainPresenter {
    
    // MARK: - Dependencies
    private var assembler = TodoAssembly()
    var networkService = NetworkService()
    private var todoItems:FileCache = FileCache()
    weak var view: MainViewController?
    
    private var retryCount = 0
    private let maxRetryCount = 5
    private var fetchRequestStart = false
    private let minDelay: Double = 2
    private let maxDelay: Double = 6
    private let factor: Double = 1.5
    private let jitter: Double = 0.05
    private var currentDelay: Double = 2
    
    // MARK: - Init
    
    func initialize() {
    }
    
    // MARK: - ViewDidLoad
    
    func viewDidLoad() {
        view?.updateActivityIndicator(isAnimating: true)
        assembler.setdelegate(item: self)
        Task {
            await view?.configure()
            try await syncWithServer()
            await view?.setSectionViewCount(with: todoItems.getAll().filter({$0.isDone == true}).count)
            await view?.updateActivityIndicator(isAnimating: false)
        }
    }
}

// MARK: - Public

extension MainPresenter {
    
    func getAllItemsCount() -> Int {
        return todoItems.todoItems.count
    }
    func getAllItems() -> [TodoItem] {
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
        let newVc = UINavigationController(rootViewController: assembler.createTodoViewController(with: newItem))
        newVc.transitioningDelegate = self.view
        self.view?.navigationController?.present(newVc, animated: true)
    }
    func updateDone(item: TodoItem) {
        self.updateDoneToNetworkService(item: item, retryCount: 0, delay: minDelay)
    }
}

private extension MainPresenter {
    
    // MARK: - Converters
    
    private func makeTodoModelList(items: [TodoItem]) -> [Todomodel] { // Конвертер
        var newArray: [Todomodel] = []
        for item in items {
            newArray.append(Todomodel(item: item))
        }
        return newArray
    }
    private func makeToDoItems(from models: [Todomodel]) -> [TodoItem] { // Конвертер
        var items: [TodoItem] = []
        for model in models {
            items.append(TodoItem(fromDTO: model))
        }
        return items
    }
    // MARK: - Load local items
    
    private func loadFromDBIfDirty() async throws {
        //   if defaults.bool(forKey: Constants.dirtyKey) { // Если isDirty true
        todoItems.setAll(items: [], fromDB: true) // Взять из БД все итемы
        await self.view?.setSectionViewCount(with:  self.todoItems.getAll().filter({$0.isDone == true}).count) // Обновить количество выполненных
        await syncIfDirty() // Попытаться заапдейтить на сервер, на случай если интернет появился, чтобы не потерять локальные изменения
    }
}

// MARK: - ITodoPresenterDelegate

extension MainPresenter: ITodoPresenterDelegate {
    func saveTodo(item: TodoItem) {
        todoItems.add(todoItem: item)
        uploadItemToNetworkService(item: item,
                                   retryCount: 0,
                                   delay: minDelay)
    }
    
    func removeTodo(item: TodoItem) {
        todoItems.removeTodoItem(by: item.id)
        removeFromNetworkService(item: item, retryCount: 0, delay: minDelay)
        view?.setSectionViewCount(with: todoItems.getAll().filter({$0.isDone == true}).count)
        view?.reloadTable()
    }
}

// MARK: - Delay
extension MainPresenter {
    private func getNextDelay(currentDelay: Double) -> Double {
        let randomJitter = Double.random(in: 0...(jitter * currentDelay))
        return min(maxDelay, factor * currentDelay) + randomJitter
    }
}

// MARK: - Network

private extension MainPresenter {
    
    private func syncWithServer() async throws {
        do {
            if defaults.bool(forKey: Constants.dirtyKey) {
                try await loadFromDBIfDirty()  // Загрузка итемов из БД, если флаг isDirty true
            } else {
                try await reloadAllTodos() // Попытка загрузки итемов из интернета
            }
        } catch {
            print(error)
        }
    }
    
    // MARK: - Reload todo items
    
    private func reloadAllTodos() async throws { // Перезагрузка всех тудуайтемов с сервера, в т.ч. перезапись БД
        let newItems = try await loadItems() // Загрузка айтемов
        // if !defaults.bool(forKey: Constants.dirtyKey) { // Если isDirty != true (т.е синхронизирована локальная база с сервером)
        todoItems.removeAll() // Очистить айтемы и БД
        // TodoDB.instance.clearTable()
        todoItems.clearLocalDB()
        for item in newItems {
            todoItems.add(todoItem: item) // Загрузить новые значения с сервера и заполнить бд
            // TodoDB.instance.addTodo(item: item)
            todoItems.itemToDB(.add, item: item)
        }
        //   }
    }
    // MARK: - Load todo items
    
    private func loadItems() async throws -> [TodoItem] { // Получить с сервера список айтемов
        do {
            let toDoModels = try await networkService.getList()
            return makeToDoItems(from: toDoModels) // Сконвертировать из ДТО  в модель
        } catch {
            print(error, ".Try to load from local file")
            do {
                // return try loadFromFile()
                defaults.set(true, forKey:Constants.dirtyKey) // Если не получилось то isDirty = true
                try await loadFromDBIfDirty() // Попытаться восстановить список с помощью БД
            } catch {
                print(error, ".Can't load from file")
            }
        }
        return []
    }
    
    // MARK: - Patch list if dirty
    
    private func syncIfDirty() async { // Patch списка айтемов на сервер, если флаг isDirty = true
        
        if defaults.bool(forKey: Constants.dirtyKey) {
            do {
                let newItems = try await updateList(items: makeTodoModelList(items: todoItems.todoItems))
                todoItems.removeAll()
                // TodoDB.instance.clearTable() >????? Не понятно работает ли без этого
                for item in newItems {
                    todoItems.add(todoItem: item)
                    //   TodoDB.instance.addTodo(item: item) ??? Не понятно работает ли без этого
                } // Отправка запроса на сервер и обновления списка айтемов
                defaults.set(false, forKey: Constants.dirtyKey)
            } catch {
            }
        }
    }
    
    // MARK: - Add Element
    
    private func uploadItemToNetworkService(item: TodoItem, retryCount: Int, delay: Double) {
        //  TodoDB.instance.addTodo(iid: item.id, iitext: item.text, ideadline: item.deadline, ipriority: item.priority.rawValue, iisDone: item.isDone, ihexcode: item.hexCode, idateCreated: item.dateCreated, idateChanged: item.dateChanged)
        //        TodoDB.instance.addTodo(item: item)
        if retryCount < 1 { // Перед первым ретраем
            DispatchQueue.main.async {
                //    self.view?.updateActivityIndicator(isAnimating: false)
                self.view?.reloadTable()
                self.todoItems.itemToDB(.upsert, item: item) // Добавление или обновления итема в БД
                //self.saveAll(withError: false)
            }
        }
        Task {
            do {
                await syncIfDirty() // Если флаг isDirty = true, нужно Обновить список сначала
                await view?.updateActivityIndicator(isAnimating: true)
                try await networkService.uploadItem(item: Todomodel(item: item)) // Загрузить на сервер
            } catch URLErrors.errorCode(Constants.unsynchronizedErrorCode) { // Ревизия не совпала -> список изменился, надо новую версию
                try await syncWithServer() // Синк с сервером, получение актуального списка
                uploadItemToNetworkService(item: item,
                                           retryCount: retryCount,
                                           delay: delay) // Пробуем ещё раз
                todoItems.add(todoItem: item) // Добавляем опять в итемы ( т.к. загрузка с сервера обновила не только ревизию, но и элементы)
                
                // await self.view?.reloadTable()
                
            } catch URLErrors.errorCode(Constants.duplicateErrorCode) { // Если элемент уже есть и его нужно обновить
                var newItem = Todomodel(item: item)
                newItem.updateID() // Проставим ID девайса, который обновлял // TODO: наверное надо где то в другом месте это делать. как вариант
                try await updateItemWithNetworkService(item: newItem) // Пробуем обновить элемент отдельно
                
            } catch {
                defaults.set(true, forKey:Constants.dirtyKey) // Интернета нет? флаг тру
                // itemToDB(.upsert, item: item)
                
                if retryCount <= Constants.maxRetryCount {
                    try await Task.sleep(nanoseconds: UInt64(delay*Constants.secondInNanoSeconds))
                    uploadItemToNetworkService(item: item,
                                               retryCount: retryCount + 1,
                                               delay: getNextDelay(currentDelay: delay))
                } else {
                    print(error, "Cant't save to server. Trying save to file")
                    ///   self.saveAll(withError: true)
                }
            }
            DispatchQueue.main.async {
                self.view?.updateActivityIndicator(isAnimating: false)
                self.view?.reloadTable()
                //  self.saveAll(withError: false)
            }
        }
    }
    
    // MARK: - Remove Element
    
    private func removeFromNetworkService(item: TodoItem, retryCount: Int, delay: Double) {
        if retryCount < 1 { // На первой попытке отправки
            DispatchQueue.main.async { //  обновить UI
                self.view?.reloadTable()
                //  todoItems.itemToDB(<#T##action: saveType##saveType#>, item: <#T##TodoItem#>)
                self.todoItems.itemToDB(.delete, item: item) // Обновить БД
            }
        }
        Task {
            do {
                await syncIfDirty() // Если флаг isDirty = true, нужно Обновить список сначала, запатчив локальные изменения
                await view?.updateActivityIndicator(isAnimating: true) // Включить анимацию
                try await networkService.removeElement(by: Todomodel(item: item).id) // Отправить запрос на удаление с сервера
            } catch URLErrors.errorCode(Constants.unsynchronizedErrorCode) { // Ошибка с ревизией
                try await syncWithServer() // Взять новую ревизию и актуальный список
                todoItems.removeTodoItem(by: item.id) // Удалить из айтемов ещё раз
                removeFromNetworkService(item: item, retryCount: retryCount, delay: delay) // Удалить с сервера ещё раз
            } catch URLErrors.noFound { // Если элемент уже удалён
                print(URLErrors.noFound, "Can't find element")
            } catch {
                // self.saveAll(withError: true)
                defaults.set(true, forKey:Constants.dirtyKey) // Если интернет не появился
                // TODO: Надо все таки поставить флаг на false, если вдруг получилось. где то
                if retryCount <= Constants.maxRetryCount {
                    try await Task.sleep(nanoseconds: UInt64(delay*Constants.secondInNanoSeconds)) // Повторить ещё раз
                    removeFromNetworkService(item: item,
                                             retryCount: retryCount + 1,
                                             delay: getNextDelay(currentDelay: delay))
                } else {
                    print(error, "Cant't save to server. Trying save to file") // Ошибка после последней попытки сохранить. можно что то на неё придумать. Может перекрасить лоадер
                }
            }
            DispatchQueue.main.async {
                self.view?.updateActivityIndicator(isAnimating: false) // Отключить лоадер
                self.view?.reloadTable() // Перезагрузить таблицу
                //   self.saveAll(withError: false)
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
    private func updateList(items: [Todomodel]) async throws -> [TodoItem] {
        let toDoModels = try await networkService.updateList(list: items )
        return makeToDoItems(from: toDoModels)
    }
    
    // Функция для обновления статуса задачи
    
    private func updateDoneToNetworkService(item: TodoItem, retryCount: Int, delay: Double) {
        if retryCount < 1 {
            DispatchQueue.main.async {
                self.view?.setSectionViewCount(with: self.todoItems.getAll().filter({$0.isDone == true}).count) // Обновить количество выполненных дел
                self.view?.reloadTable() // перезагрузить таблицу
                self.todoItems.itemToDB(.update, item: item) // обновить итем в бд
            }
        }
        Task {
            do {
                await syncIfDirty() // Если флаг isDirty = true, нужно Обновить список сначала по возможности
                await view?.updateActivityIndicator(isAnimating: true) // Запустить анимашку
                try await networkService.updateElement(elment: Todomodel(item: item)) // Обновить на сервере
            } catch URLErrors.errorCode(Constants.unsynchronizedErrorCode) { // Ревизия не совпала
                try await syncWithServer() // Засинхронизироваться, взять ревизию и список актуальный
                var item2 = item
                item2.setDone(flag: item.isDone) // Т.к данные с сервера взяты надо еще раз проставить флаг
                todoItems.add(todoItem: item2)
                updateDone(item:  item2)
                self.todoItems.itemToDB(.update, item: item2) 
            } catch URLErrors.noFound {
                print(URLErrors.noFound, "Can't find element")
            } catch {
                defaults.set(true, forKey:Constants.dirtyKey) //  ставим флаг
                if retryCount <= Constants.maxRetryCount {
                    try await Task.sleep(nanoseconds: UInt64(delay*Constants.secondInNanoSeconds))
                    updateDoneToNetworkService(item: item, retryCount: retryCount + 1, delay: getNextDelay(currentDelay: delay))
                } else { // Однако когда интернет появился бы может в пятую попытку надо бы флаг убрать. надо найти где, мб в диспатчкью
                    print(error, "Cant't save to server. Trying save to file")
                    //    self.saveAll(withError: true)
                }
            }
            DispatchQueue.main.async {
                //     self.view?.setSectionViewCount(with:  self.todoItems.getAll().filter({$0.isDone == true}).count)
                self.view?.reloadTable()
                self.view?.updateActivityIndicator(isAnimating: false)
                //   self.saveAll(withError: false)
            }
        }
    }
    
}
//    private func loadFromFile() throws -> [TodoItem] { // Видимо не актуально
//        try todoItems.loadTodoItems(from: Constants.fileCacheName, with: .json)
//        return todoItems.todoItems
//    }
//    private func itemToDB(_ action: saveType,item: TodoItem) {
//
//        do {
//
//           // TodoDB.instance.saveAll(items: getAllItems())
//           // try todoItems.saveTodoItems(to: Constants.fileCacheName, with: .json)
//            switch action {
//
//            case .update:
//                TodoDB.instance.updateTodo(item: item)
//            case .add:
//                TodoDB.instance.addTodo(item: item)
//            case .delete:
//                TodoDB.instance.deleteTodo(id: item.id)
//            case .upsert:
//                TodoDB.instance.saveOrUpdate(item: item)
//            }
//        } catch {
//            print (error,"Can't save to file")
//        }
//        DispatchQueue.main.async {
//            self.view?.reloadTable()
//        }
//
//}
//    private func saveAll(withError: Bool, type: saveType) {
//
//        print("saved")
//        do {
//            if withError || defaults.bool(forKey: Constants.dirtyKey) {
//                defaults.set(true, forKey:Constants.dirtyKey)
//            }
//            TodoDB.instance.saveAll(items: getAllItems())
//           // try todoItems.saveTodoItems(to: Constants.fileCacheName, with: .json)
//
//        } catch {
//            print (error,"Can't save to file")
//        }
//        DispatchQueue.main.async {
//            self.view?.reloadTable()
//        }
//    }

//syncwithserver
//            if defaults.bool(forKey: Constants.dirtyKey) {
//                try self.todoItems.loadTodoItems(from: Constants.fileCacheName, with: .json)
//           //     await syncIfDirty()
//            }
//try self.todoItems.loadTodoItems(from: Constants.fileCacheName, with: .json)
//TodoDB.instance.getAllTodoItems()
// IFDIRTY\
//            if defaults.bool(forKey: Constants.dirtyKey) {
//            todoItems.setAll(items: TodoDB.instance.getAllTodoItems())
//            await self.view?.setSectionViewCount(with:  self.todoItems.getAll().filter({$0.isDone == true}).count)
//            ///
//            ///
//            ///
//            await syncIfDirty()
//
//             }

