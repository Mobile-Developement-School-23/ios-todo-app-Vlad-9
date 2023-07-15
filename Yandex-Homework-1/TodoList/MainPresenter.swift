import Foundation
import CocoaLumberjack
import TodoItem

extension MainPresenter {
    
    // MARK: - Constants
    
    enum Constants {
        static let dirtyKey = "isDirty"
        static let fileCacheName = "SavedJsonItems"
        static let unsynchronizedErrorCode = "unsynchronized data"
        static let duplicateErrorCode = "duplicate item"
        static let secondInNanoSeconds: Double = 1_000_000_000
    }
    
    // MARK: - Messagges for banner
    
    enum BannerMesagges {
        static let syncWithServerMessage = NSLocalizedString("message.syncWithServer",
                                                             comment: "")
        static let syncWithLocalDBMessage = NSLocalizedString("message.syncWithLocalDB",
                                                              comment: "")
        static let errorGetDataFromServerMessage = NSLocalizedString("message.errorGetDataFromServer", comment: "")
        static let errorGetDataFromLocalDBMessage = NSLocalizedString("message.errorGetDataFromLocalDB", comment: "")
        static let warningDelayNetworkMessage = NSLocalizedString("message.warningDelayNetwork",
                                                                  comment: "")
        static let errorSendDataToServerMessage = NSLocalizedString("message.errorSendDataToServer", comment: "")
        static let warningElementAlreadyDeletedMessage = NSLocalizedString("message.warningElementAlreadyDeleted", comment: "")
    }
    
    // MARK: - Settings for retry function
    
    enum RetrySettings {
        static let minDelay: Double = 2
        static let maxDelay: Double = 100
        static let factor: Double = 1.5
        static let jitter: Double = 0.05
        static let maxRetryCount = 5
    }
}

final class MainPresenter {
    
    // MARK: - Dependencies
    
    private var updateCounter = 0
    private var _netCounter: Int = 0
    var currentDelay: Double = 2
    private var retryCount = 0
    
    private var assembler = TodoAssembly()
    private var networkService = NetworkService()
    private var todoItems: FileCache = FileCache()
    weak var view: MainViewController?
    
    private var contextChanged = false
    private var refreshFlag = false
    private var fetchRequestStart = false
    private var mutex = NSLock()
    private var netCounter: Int {
        get {
            mutex.withLock {
                _netCounter
            }
        }
        set {
            if newValue > 0 {
                DispatchQueue.main.async {
                    self.view?.updateActivityIndicator(isAnimating: true)
                    // Включить анимацию, когда появятся запросы в сеть
                }
            } else {
                DispatchQueue.main.async {
                    self.view?.updateActivityIndicator(isAnimating: false)
                    // Выключить анимацию, когда запросы закончатся
                }
            }
            mutex.withLock {
                _netCounter = newValue
            }
        }
    }
    
    // MARK: - ViewDidLoad
    
    func viewDidLoad() {
        assembler.setdelegate(item: self)
        Task {
            await view?.configure()
            try await syncWithServer()
            await view?.setSectionViewCount(with: todoItems.getAll().filter({$0.isDone == true}).count)
            await self.view?.reloadTable()
        }
    }
}

// MARK: - Public
// TODO: - В протокол вынести

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
    func refresh() {
        self.refreshFlag = true
        Task {
            do {
                try await self.reloadAllTodos()
            } catch {
                print(error)
            }
            await self.view?.setSectionViewCount(with: self.todoItems.getAll().filter({$0.isDone == true}).count)
            await view?.reloadTable()
            await self.view?.stopRefresh()
        }
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
        self.updateDoneToNetworkService(item: item, retryCount: 0, delay: RetrySettings.minDelay)
    }
}

// MARK: - Private

private extension MainPresenter {
    
    // MARK: - Converters
    
    private func makeTodoModelList(items: [TodoItem]) -> [Todomodel] {
        var newArray: [Todomodel] = []
        for item in items {
            newArray.append(Todomodel(item: item))
        }
        return newArray
    }
    private func makeToDoItems(from models: [Todomodel]) -> [TodoItem] {
        var items: [TodoItem] = []
        for model in models {
            items.append(TodoItem(fromDTO: model))
        }
        return items
    }
    
    // MARK: - Load local items
    
    private func loadFromDBIfDirty() async throws {
        todoItems.setAll(items: [], fromDB: true) // Взять из БД все итемы
        await self.view?.setSectionViewCount(with: self.todoItems.getAll().filter({$0.isDone == true}).count)
        await syncIfDirty()
        // Попытаться заапдейтить на сервер, на случай если интернет появился, чтобы не потерять локальные изменения
    }
}

// MARK: - ITodoPresenterDelegate

extension MainPresenter: ITodoPresenterDelegate {
    func saveTodo(item: TodoItem) {
        todoItems.add(todoItem: item)
        uploadItemToNetworkService(item: item,
                                   retryCount: 0,
                                   delay: RetrySettings.minDelay)
    }
    
    func removeTodo(item: TodoItem) {
        todoItems.removeTodoItem(by: item.id)
        removeFromNetworkService(item: item, retryCount: 0, delay: RetrySettings.minDelay)
        view?.setSectionViewCount(with: todoItems.getAll().filter({$0.isDone == true}).count)
    }
}

// MARK: - Delay

extension MainPresenter {
    private func getNextDelay(currentDelay: Double) -> Double {
        let randomJitter = Double.random(in: 0...(RetrySettings.jitter * currentDelay))
        return min(RetrySettings.maxDelay, RetrySettings.factor * currentDelay) + randomJitter
    }
}

// MARK: - Network

private extension MainPresenter {
    
    private func syncWithServer() async throws {
        do {
            if defaults.bool(forKey: Constants.dirtyKey) {
                try await loadFromDBIfDirty()
                // Загрузка итемов из БД, если флаг isDirty true
                await self.view?.showbanner(text: BannerMesagges.syncWithLocalDBMessage,color: Colors.colorRed.value)
            } else {
                try await reloadAllTodos()
                // Попытка загрузки итемов из интернета
                 await view?.reloadTable()
            
            }
            self.contextChanged = false
        } catch {
            print(error)
        }
    }
    
    // MARK: - Reload todo items
    
    private func reloadAllTodos() async throws {
        // Перезагрузка всех тудуайтемов с сервера, в т.ч. перезапись БД
        let newItems = try await loadItems()
        if !defaults.bool(forKey: Constants.dirtyKey) {
            todoItems.removeAll()
            todoItems.clearLocalDB()
            for item in newItems {
                todoItems.add(todoItem: item)
                // Загрузить новые значения с сервера и заполнить бд
                todoItems.itemToDB(.add, item: item)
            }
            await view?.setSectionViewCount(with: todoItems.getAll().filter({$0.isDone == true}).count)
            await self.view?.showbanner(text: BannerMesagges.syncWithServerMessage,color: Colors.colorGreen.value)
        } else {
            await syncIfDirty()
        }
    }
    // MARK: - Load todo items
    
    private func loadItems() async throws -> [TodoItem] {
        self.netCounter += 1
        // Запрос в сеть начался
        do {
            let toDoModels = try await networkService.getList()
            self.netCounter -= 1
            // Запрос в сеть окончен
            return makeToDoItems(from: toDoModels)
        } catch {
            defaults.set(true, forKey: Constants.dirtyKey)
            await self.view?.showbanner(text: BannerMesagges.errorGetDataFromServerMessage,
                                        color: Colors.colorRed.value)
            print(error, ".Try to load from local file")
            do {
                try await loadFromDBIfDirty()
                // Попытаться восстановить список с помощью БД
                self.netCounter -= 1
                // Запрос в сеть окончен
            } catch {
                await self.view?.showbanner(text: BannerMesagges.errorGetDataFromLocalDBMessage, color: Colors.colorRed.value)
                print(error, ".Can't load from file")
            }
        }
        return []
    }
    
    // MARK: - Patch list if dirty
    
    private func syncIfDirty() async {
        // Patch списка айтемов на сервер, если флаг isDirty = true
        if defaults.bool(forKey: Constants.dirtyKey) {
            do {
                let newItems = try await updateList(items: makeTodoModelList(items: todoItems.todoItems))
                todoItems.removeAll()
                todoItems.clearLocalDB()
                for item in newItems {
                    todoItems.add(todoItem: item)
                    todoItems.itemToDB(.add, item: item)
                }
                defaults.set(false, forKey: Constants.dirtyKey)
                await self.view?.showbanner(text: BannerMesagges.syncWithServerMessage,color: Colors.colorGreen.value)
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Add Element
    
    private func uploadItemToNetworkService(item: TodoItem, retryCount: Int, delay: Double) {
        self.netCounter += 1
        // Запрос в сеть начался
        if retryCount < 1 {
            DispatchQueue.main.async {
                self.view?.reloadTable()
            }
            var newItem = item
            newItem.setUpdatedID()
            self.todoItems.itemToDB(.upsert, item: newItem)
            // Добавление или обновления итема в БД
        }
        Task {
            do {
                await syncIfDirty()
                // Если флаг isDirty = true, нужно Обновить список сначала
                try await networkService.uploadItem(item: Todomodel(item: item))
                // Загрузить на сервер
            } catch URLErrors.errorCode(Constants.unsynchronizedErrorCode) {
                await self.view?.showbanner(text: BannerMesagges.warningDelayNetworkMessage, color: .orange)
                self.contextChanged = true
                // Контекст изменился
                try await self.networkService.getList()
                // Обновить ревизию
                uploadItemToNetworkService(item: item,
                                                     retryCount: retryCount,
                                                     delay: delay)
            } catch URLErrors.errorCode(Constants.duplicateErrorCode) {
                // Если элемент уже есть и его нужно обновить
                var newItem = Todomodel(item: item)
                newItem.updateID()
                // Проставим ID девайса, который обновлял
                 await updateItemWithNetworkService(item: newItem)
                // Пробуем обновить элемент
            } catch {
                defaults.set(true, forKey: Constants.dirtyKey)
                if retryCount == 1 {
                    await self.view?.showbanner(text: BannerMesagges.warningDelayNetworkMessage,
                                                color: .orange)
                }
                if retryCount <= RetrySettings.maxRetryCount {
                    try await Task.sleep(nanoseconds: UInt64(delay*Constants.secondInNanoSeconds))
                    uploadItemToNetworkService(item: item,
                                               retryCount: retryCount + 1,
                                               delay: getNextDelay(currentDelay: delay))
                } else {
                    await self.view?.showbanner(text: BannerMesagges.errorSendDataToServerMessage,color: Colors.colorRed.value)
                    print(error, "Cant't save to server. Trying save to file")
                }
            }
            //            DispatchQueue.main.async {
            self.netCounter -= 1
            // Запрос в сеть окончен
            if self.netCounter == 0 && self.contextChanged {
                // После того, как закночатся походы в сеть и если контекст изменился (ревизия)
                Task {
                    try await self.syncWithServer()
                    // Загрузить данные с сервера ( вдруг кто нибудь ещё внес изменения )
                }
                //                }
            }
        }
    }
    
    // MARK: - Remove Element
    
    private func removeFromNetworkService(item: TodoItem, retryCount: Int, delay: Double) {
        self.netCounter += 1
        if retryCount < 1 {
            DispatchQueue.main.async {
                self.view?.reloadTable()
            }
            self.todoItems.itemToDB(.delete, item: item)
        }
        Task {
            do {
                if retryCount < 1 {
                    await syncIfDirty()
                    // Если флаг isDirty = true, нужно Обновить список сначала, запатчив локальные изменения
                }
                try await networkService.removeElement(by: Todomodel(item: item).id)
                // Отправить запрос на удаление с сервера
                defaults.set(false, forKey: Constants.dirtyKey)
            } catch URLErrors.errorCode(Constants.unsynchronizedErrorCode) { // Ошибка с ревизией
                await self.view?.showbanner(text: BannerMesagges.warningDelayNetworkMessage,
                                            color: .orange)
                self.contextChanged = true
                try await self.networkService.getList()
                // Обновить контекст
                removeFromNetworkService(item: item, retryCount: retryCount+1, delay: delay)
            } catch URLErrors.noFound { // Если элемент уже удалён
                await self.view?.showbanner(text: BannerMesagges.warningElementAlreadyDeletedMessage,
                                            color: .orange)
                print(URLErrors.noFound, "Can't find element")
            } catch {
                defaults.set(true, forKey: Constants.dirtyKey)
                // Если интернет не появился
                if retryCount == 1 {
                    await self.view?.showbanner(text: BannerMesagges.warningDelayNetworkMessage,
                                                color: .orange)
                }
                if retryCount <= RetrySettings.maxRetryCount {
                    try await Task.sleep(nanoseconds: UInt64(delay*Constants.secondInNanoSeconds)) // Повторить ещё раз
                    removeFromNetworkService(item: item,
                                             retryCount: retryCount + 1,
                                             delay: getNextDelay(currentDelay: delay))
                } else {
                    await self.view?.showbanner(text: BannerMesagges.errorSendDataToServerMessage,color: Colors.colorRed.value)
                    print(error, "Retry count reach maximum")
                    // Ошибка после последней попытки сохранить. можно что то на неё придумать. Может перекрасить лоадер
                }
            }
            //            DispatchQueue.main.async {
            self.netCounter -= 1
            // Завершить походы в сеть
            if self.netCounter == 0 && self.contextChanged {
                // После того, как закночатся походы в сеть и если контекст изменён
                Task {
                    try await self.syncWithServer()
                    // Загрузить данные с сервера ( вдруг кто нибудь ещё внес изменения )
                }
                //                }
            }
        }
    }
    
    private func updateItemWithNetworkService(item: Todomodel) async {
        do {
            try await networkService.updateElement(elment: item)
        } catch {
            print(error, "Cant'update Element")
        }
        //        DispatchQueue.main.async {
        //            //   self.view?.reloadTable()
        //        }
    }
    
    private func updateList(items: [Todomodel]) async throws -> [TodoItem] {
        let toDoModels = try await networkService.updateList(list: items )
        return makeToDoItems(from: toDoModels)
    }
    
    // Функция для обновления статуса задачи
    
    private func updateDoneToNetworkService(item: TodoItem, retryCount: Int, delay: Double) {
        self.netCounter += 1
        if retryCount < 1 {
            //            DispatchQueue.main.async {
            var newItem = item
            newItem.setUpdatedID()
            self.todoItems.itemToDB(.update, item: newItem)
            // обновить итем в бд
            //            }
        }
        Task {
            do {
                await syncIfDirty()
                // Если флаг isDirty = true, нужно Обновить список сначала по возможности
                try await networkService.updateElement(elment: Todomodel(item: item))
            } catch URLErrors.errorCode(Constants.unsynchronizedErrorCode) {
                await self.view?.showbanner(text: BannerMesagges.warningDelayNetworkMessage, color: .orange)
                // Ревизия не совпала
                self.contextChanged = true
                try await networkService.getList()
                updateDoneToNetworkService(item: item, retryCount: retryCount, delay: delay)
            } catch URLErrors.noFound {
                print(URLErrors.noFound, "Can't find element")
            } catch {
                defaults.set(true, forKey: Constants.dirtyKey)
                if retryCount == 1 {
                    await self.view?.showbanner(text: BannerMesagges.warningDelayNetworkMessage,
                                                color: .orange)
                }
                if retryCount <= RetrySettings.maxRetryCount {
                    try await Task.sleep(nanoseconds: UInt64(delay*Constants.secondInNanoSeconds))
                    updateDoneToNetworkService(item: item,
                                               retryCount: retryCount + 1,
                                               delay: getNextDelay(currentDelay: delay))
                } else {
                    await self.view?.showbanner(text: BannerMesagges.errorSendDataToServerMessage,color: Colors.colorRed.value)
                    print(error, "Cant't save to server. Trying save to file")
                }
            }
            //            DispatchQueue.main.async {
            self.netCounter -= 1
            if self.netCounter == 0 && self.contextChanged { // После того, как закночатся походы в сеть
                Task {
                    try await self.syncWithServer()
                    // Загрузить данные с сервера ( вдруг кто нибудь ещё внес изменения )
                }
                //                }
            }
        }
    }
}
