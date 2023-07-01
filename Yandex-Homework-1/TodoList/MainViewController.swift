import UIKit

class MainViewController: UIViewController, UISearchResultsUpdating, UINavigationControllerDelegate {

    //MARK: - TODO
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    //MARK: - Dependencies

    private var assembler = TodoAssembly()
    var showisDone = false
    let transition = Animator()
    var selectedCell: UITableViewCell?
    private var todoItems:FileCache = FileCache()
    
    //MARK: - UI

    private let sectionView = TodoDoneUIView()
    private  var backButton =  UIButton(type: .system)
    private  var emptyButton =  UIButton(type: .system)

    private lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .insetGrouped
        )
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TodoTableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.register(CreateNewTaskTableViewCell.self, forCellReuseIdentifier: "cellId2")
        return tableView
    }()
    
    // MARK: Floating button
    
    private let plusButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0,
                                            y: 0,
                                            width: 60,
                                            height: 60))
        
        button.backgroundColor = Colors.colorBlue.value
        button.tintColor = .white
        
        let image = UIImage(systemName: "plus",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 32,
                                                                           weight: .medium))
        
        button.setImage(image, for: .normal)
      //  button.layer.shadowPath = cg
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.layer.cornerRadius = 25
        button.layer.shadowOffset = CGSize(width: 0, height: 8)
//        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.4)
        button.layer.shadowColor = Colors.colorBlue.cgColor
//                self.layer.shadowOpacity = 0.5
//                self.layer.shadowRadius = 1.5
        return button
    }()
    
    private lazy var taskLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text =   NSLocalizedString("task.title", comment: "title for task")
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = Colors.labelPrimary.value
        return label
    }()
   
    //MARK: - Init
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.delegate = self
        self.view.backgroundColor = Colors.backPrimary.value
        self.tableView.backgroundColor = Colors.backPrimary.value
        configure()
    }
    
    //MARK: - Configure

    func configure() {
        loadItems()
        setupButton()
        confNav()
        sectionView.delegate = self
        self.assembler.setdelegate(item: self)
        setupLayout()
        sectionView.configure(with: todoItems.getAll().filter({$0.isDone == true}).count)
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableView.automaticDimension
    }

    func setupButton() {

        view.addSubview(tableView)
        self.view
            .addSubview(plusButton)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
            
        plusButton.addTarget(self, action: #selector(createTask), for: .touchUpInside)
        
        plusButton.widthAnchor.constraint(
                equalToConstant: 50).isActive = true
        plusButton.heightAnchor.constraint(
                equalToConstant: 50).isActive = true
        plusButton.centerXAnchor.constraint(
                equalTo: self.view.centerXAnchor).isActive = true
        plusButton.bottomAnchor.constraint(
                equalTo: self.view.layoutMarginsGuide.bottomAnchor,
                constant: -10).isActive = true

    }
    @objc func createTask() {
        presentViewWithNewTask()
    }

    private func confNav() {
        self.navigationController?.navigationBar.topItem?.title = "Мои дела"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.layoutMargins.left = 32
        self.navigationItem.largeTitleDisplayMode = .automatic
    }
    
    //MARK: - Layout
    
    private func setupLayout() {
     
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 0)
        tableView.layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
       // setupbutton()
        
    //    view.addSubview(emptyButton)
        
//        backButton.translatesAutoresizingMaskIntoConstraints = false
//        emptyButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            //emptyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor,constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
           // emptyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -10),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
}
//MARK: - MainViewController private

private extension MainViewController {
    private func loadItems() {
       
        do {
            try todoItems.loadTodoItems(from: "SavedJsonItems", with: .json)
            
        } catch {
    
        }
    }
    
    private func saveAll() {
        do {
            try todoItems.saveTodoItems(to: "SavedJsonItems", with: .json)
           
        } catch {
        }

    }
}

//MARK: - ITodoPresenterDelegate

extension MainViewController: ITodoPresenterDelegate {

    func saveTodo(item: TodoItem) {
        todoItems.add(todoItem: item)
        self.saveAll()
                DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
    }
    func removeTodo(item: TodoItem) {
        todoItems.removeTodoItem(by: item.id)
        self.saveAll()
                DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
       // sectionView.configure(with: todoItems.getAll().filter({$0.isDone == true}).count)
        sectionView.configure(with: todoItems.getAll().filter({$0.isDone == true}).count)
    }
}

//MARK: - Button handlers

extension MainViewController {
    @objc func presentViewWithNewTask() {
        var newVc = UINavigationController(rootViewController: assembler.createTodoViewController(with: nil))
         newVc.transitioningDelegate = self
         self.navigationController?.present(newVc, animated: true)

    }
    func presentViewWith(id: String) {
     
        let newItem =  todoItems.getAll().first(where: {$0.id == id})
       var newVc = UINavigationController(rootViewController: assembler.createTodoViewController(with: newItem))
  
        newVc.transitioningDelegate = self

        self.navigationController?.present(newVc, animated: true)

    }
//    @objc func presentView() {
//        let model = todoItems.getAll().last
//        self.navigationController?.present(UINavigationController(rootViewController: assembler.createTodoViewController(with: loadItems())), animated: true)
//    }
}

//MARK: -  UITableViewDelegate,UITableViewDataSource

extension MainViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showisDone {
            return todoItems.getAll().count+1
        } else {
            return todoItems.getAll().filter({$0.isDone != true}).count+1
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let cornerRadius = 16
        var corners: UIRectCorner = []
        
        if indexPath.row == 0
        {
            corners.update(with: .topLeft)
            corners.update(with: .topRight)
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)
        }
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: cell.bounds,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: cornerRadius,
                                                          height: cornerRadius)).cgPath
        cell.layer.mask = maskLayer
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row != tableView.numberOfRows(inSection: indexPath.section) - 1 {
            var todomodel: TodoItem?
            if showisDone {
                todomodel = todoItems.getAll()[indexPath.row]
            } else {
                todomodel = todoItems.getAll().filter({$0.isDone != true})[indexPath.row]
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! TodoTableViewCell
            cell.delegate = self
            if let todomodel {
                var labelColor = UIColor()
                if let todocolor = todomodel.hexCode {
                    labelColor = UIColor(hex: todocolor) ?? Colors.labelPrimary.value
                } else {
                    labelColor = Colors.labelPrimary.value
                }
                var model = CellModel(text: todomodel.text,
                                      date: todomodel.deadline,
                                      id: todomodel.id,
                                      isDone: todomodel.isDone,
                                      color: labelColor,
                                      priority: todomodel.priority)
                
                cell.indexp = indexPath
                
                cell.configure(model: model)
                cell.setButtonImage(flag: todomodel.isDone, priority: todomodel.priority)
            }
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "cellId2", for: indexPath) as! CreateNewTaskTableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            presentViewWithNewTask()
        } else {
            var todomodel: TodoItem?
            if showisDone {
                todomodel = todoItems.getAll()[indexPath.row]
            } else {
                todomodel = todoItems.getAll().filter({$0.isDone != true})[indexPath.row]
            }
            if let todomodel {
                presentViewWith(id: todomodel.id)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func getTodoItem(parameter: Bool,path: IndexPath) -> TodoItem?{
        if parameter {
            return todoItems.getAll()[path.row]
        } else {
            return todoItems.getAll().filter({$0.isDone != true})[path.row]
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row != tableView.numberOfRows(inSection: indexPath.section) - 1 {
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
   
                if let todomodel = self.getTodoItem(parameter: self.showisDone, path: indexPath) {
                    self.removeTodo(item: todomodel)
                    self.tableView.reloadData()
                    completionHandler(true)
                }
            }
            
            deleteAction.image = UIImage(systemName: "trash.fill")
            deleteAction.backgroundColor = Colors.colorRed.value
            let info = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
                if let todomodel = self.getTodoItem(parameter: self.showisDone, path: indexPath){
                    self.presentViewWith(id: todomodel.id)
                }
                completionHandler(true)
            }
            info.image = UIImage(named: "infoIcon")
            info.backgroundColor = Colors.colorGrayLight.value
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction,info])
            return configuration
        }
        return nil
    }

        func tableView(
            _ tableView: UITableView,
            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
                if indexPath.row != tableView.numberOfRows(inSection: indexPath.section) - 1  {
                    
                    let title = ""
                    let action = UIContextualAction(
                        style: .normal,
                        title: title
                    )
                    { [weak self] action, view, completionHandler in
                        if let todomodel = self?.getTodoItem(parameter: self!.showisDone,
                                                             path: indexPath){
                            self?.setIsDone(id: (todomodel.id),
                                            indexPath: indexPath,
                                            animation: false)
                        }
                        completionHandler(true)
                    }
                    action.image = UIImage(named: "actionRadioButtonIcon")
                    if let todomodel = getTodoItem(parameter: self.showisDone, path: indexPath) {
                        if todomodel.isDone {
                        action.backgroundColor = Colors.colorGrayLight.value
                    } else {
                        action.backgroundColor = Colors.colorGreen.value
                    }
                }
                return UISwipeActionsConfiguration(actions: [action])
            }
        return nil
    }
}

//MARK: - TodoTableViewCellDelegate

extension MainViewController: TodoTableViewCellDelegate {
    func setIsDone(id: String,indexPath: IndexPath,animation: Bool) {
        var todomodel: [TodoItem]
        if self.showisDone {
            todomodel = self.todoItems.getAll()
        } else {
            todomodel = self.todoItems.getAll().filter({$0.isDone != true})
        }
        var newItem =  todomodel.first(where: {$0.id == id})
        let newItem2 = todoItems.getAll().filter({$0.isDone != true}).firstIndex(where: {$0.id == id})
        let value = todomodel.first(where: {$0.id == id})!.isDone
        
        newItem?.setDone(flag: !value)
        todoItems.add(todoItem: newItem!)
        saveAll()
        
        if !showisDone {
            if let index  =  newItem2{
                let indexPth = IndexPath(row: index, section: 0)
                self.tableView.deleteRows(at: [indexPth], with: .left)
            }
        } else {
            if animation {
                if value {
                    tableView.reloadRows(at: [indexPath], with: .right)
                } else {
                    tableView.reloadRows(at: [indexPath], with: .left)
                }
            } else {
                tableView.reloadRows(at:  [indexPath], with: .none)
            }
        }
        sectionView.configure(with: todoItems.getAll().filter({$0.isDone == true}).count)
    }
}

//MARK: - TodoDoneUIViewdelegate

extension MainViewController: TodoDoneUIViewdelegate {
    func showIsDone(done: Bool) {
        self.showisDone = done
        UIView.transition(with: tableView, duration: 0.7, options: .transitionFlipFromLeft, animations: {self.tableView.reloadData()
          //  self.view.setNeedsLayout()
        }, completion: nil)
    }
}

// MARK: Preview

extension MainViewController {

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        
        let previewProvider: () -> UIViewController? = {
            if indexPath.row != tableView.numberOfRows(inSection: indexPath.section) - 1  {
                if let todomodel = self.getTodoItem(parameter: self.showisDone, path: indexPath){
                    var newVc = UINavigationController(rootViewController: self.assembler.createTodoViewController(with: todomodel))
                    return newVc
                }
            }
            return nil
        }
        
        let actionsProvider: ([UIMenuElement]) -> UIMenu? = { _ in
            
            let editAction = UIAction(title: "Изменить дело", image: UIImage(systemName: "pencil")) { [weak self] _ in

                if let todomodel = self?.getTodoItem(parameter: self!.showisDone, path: indexPath){
                    let newVc = UINavigationController(rootViewController: (self?.assembler.createTodoViewController(with: todomodel))!)
                    newVc.transitioningDelegate = self
                    self?.navigationController?.present(newVc, animated: true)
                }
            }
            
            let deleteAction = UIAction(title: "Удалить дело", image: UIImage(systemName: "trash.fill"), attributes: .destructive) { [weak self] _ in
                
                if let todomodel = self?.getTodoItem(parameter: self!.showisDone, path: indexPath) {
                    self?.removeTodo(item: todomodel)
                    self?.tableView.reloadData()
                }
            }
            if indexPath.row != tableView.numberOfRows(inSection: indexPath.section) - 1  {  return UIMenu(title: "", children: [editAction, deleteAction]) }
            return nil
          
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider, actionProvider: actionsProvider)
    }
    
    func tableView(_ tableView: UITableView,
                   willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                   animator: UIContextMenuInteractionCommitAnimating) {
      guard let detailsVC = animator.previewViewController as? ViewController else {
                return
            }
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}

// MARK: Transition

extension MainViewController: UIViewControllerTransitioningDelegate {

  func animationController(forPresented presented: UIViewController,
                           presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

    guard
      let selectedIndexPathCell = tableView.indexPathForSelectedRow,
      let selectedCell = tableView.cellForRow(at: selectedIndexPathCell),
      let selectedCellSuperview = selectedCell.superview
      else {
        return nil
    }
    transition.originFrame = selectedCellSuperview.convert(selectedCell.frame, to: nil)
    transition.originFrame = CGRect(
      x: transition.originFrame.origin.x + 20,
      y: transition.originFrame.origin.y + 20,
      width: transition.originFrame.size.width - 40,
      height: transition.originFrame.size.height - 40
    )
    transition.presenting = true
    return transition
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition.presenting = false
    return transition
  }
}
