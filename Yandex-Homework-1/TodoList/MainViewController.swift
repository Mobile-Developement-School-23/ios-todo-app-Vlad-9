import UIKit
import TodoItem

private extension MainViewController {
    enum Constants {
        static let showDoneAnimationDuration = 0.7
        static let tableViewCornerRadius: CGFloat = 16
        static let plusButtonWidthAnchorConstant: CGFloat = 50
        static let plusButtonHeightAnchorConstant: CGFloat = 50
        static let activityIndicatorLeadingAnchorConstant: CGFloat = 16
        static let plusButtonBottomAnchor: CGFloat = -10
        static let navigationBarLayoutMarginsLeft: CGFloat = 32
        static let tableViewSeparatorinset = UIEdgeInsets(top: 0,
                                                          left: 52,
                                                          bottom: 0,
                                                          right: 0)
        static let tableViewLayoutMargins = UIEdgeInsets(top: 0,
                                                         left: 16,
                                                         bottom: 0,
                                                         right: 16)
        static let plusButtonRect = CGRect(x: 0,
                                           y: 0,
                                           width: 44,
                                           height: 44)
        static let plusButtonPointSize: CGFloat = 32
        static let plusButtonshadowRadius: CGFloat = 10
        static let plusButtonshadowOpacity: Float = 10
        static let plusButtonCornerRadius: CGFloat = 25
        static let plusButtonshadowOffset = CGSize(width: 0, height: 8)
        static let plusButtonImageName = "plus"
        static let trashFillImageName = "trash.fill"
        static let iconInfoImageName = "infoIcon"
        static let editIconImageName = "pencil"
        static let iconActionRadioButtonImageName = "actionRadioButtonIcon"
        static let cell1Id = "cellId"
        static let cell2Id = "cellId2"

    }
}
// MARK: - Public

extension MainViewController {
    
    func reloadTable() {
        self.tableView.reloadData()
    }
    func configure() {
        configureNavBar()
        setupButton()
        configureBackgrounds()
        setupLayout()
        configureDelegates()
    }
    func setSectionViewCount(with count: Int) {
        sectionView.configure(with: count)
        tableView.reloadData()
    }
    func updateActivityIndicator(isAnimating: Bool) {
        if isAnimating {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
    }
}

// MARK: - Private

private extension MainViewController {
    
    private func getTodoItem(parameter: Bool,path: IndexPath) -> TodoItem?{
        if parameter {
            return presenter.getAllItems()[path.row]
        } else {
            return presenter.getAllItems().filter({$0.isDone != true})[path.row]
        }
    }
    
    private func configureDelegates() {
        navigationController?.delegate = self
        sectionView.delegate = self
    }
    
    private func configureBackgrounds() {
        view.backgroundColor = Colors.backPrimary.value
        tableView.backgroundColor = Colors.backPrimary.value
    }
    
    private func setupButton() {
        
        view.addSubview(tableView)
        self.view
            .addSubview(plusButton)
        self.navigationController?.navigationBar.addSubview(activityIndicator)
        
        activityIndicator.color = Colors.colorBlue.value
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.addTarget(self, action: #selector(createTask), for: .touchUpInside)
        plusButton.widthAnchor.constraint(
            equalToConstant: Constants.plusButtonWidthAnchorConstant).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: (self.navigationController?.navigationBar.centerYAnchor)!).isActive = true
        activityIndicator.leadingAnchor.constraint(equalTo: (self.navigationController?.navigationBar.leadingAnchor)!,constant: Constants.activityIndicatorLeadingAnchorConstant).isActive = true
        plusButton.heightAnchor.constraint(
            equalToConstant: Constants.plusButtonHeightAnchorConstant).isActive = true
        plusButton.centerXAnchor.constraint(
            equalTo: self.view.centerXAnchor).isActive = true
        plusButton.bottomAnchor.constraint(
            equalTo: self.view.layoutMarginsGuide.bottomAnchor,
            constant: Constants.plusButtonBottomAnchor).isActive = true
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("task.myTasks", comment: " task")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.layoutMargins.left = Constants.navigationBarLayoutMarginsLeft
        self.navigationItem.largeTitleDisplayMode = .automatic
    }
    
    @objc private func createTask() {
        presenter.presentViewWithNewTask()
    }
    
    //MARK: - Layout
    
    private func setupLayout() {
        
        tableView.separatorInset = Constants.tableViewSeparatorinset
        tableView.layoutMargins =  Constants.tableViewLayoutMargins
        
        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}


class MainViewController: UIViewController, UINavigationControllerDelegate {
    
    //MARK: - Dependencies
    
    var showisDone = false
    let transition = Animator()
    var selectedCell: UITableViewCell?
    private var presenter: MainPresenter
    
    //MARK: - Initializer
    
    init(presenter: MainPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    private let sectionView = TodoDoneUIView()
    private var backButton =  UIButton(type: .system)
    private var emptyButton =  UIButton(type: .system)
    
    private lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .insetGrouped
        )
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TodoTableViewCell.self, forCellReuseIdentifier: Constants.cell1Id)
        tableView.register(CreateNewTaskTableViewCell.self, forCellReuseIdentifier: Constants.cell2Id)
        return tableView
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton(frame: Constants.plusButtonRect)
        
        button.backgroundColor = Colors.colorBlue.value
        button.tintColor = .white
        
        let image = UIImage(systemName: Constants.plusButtonImageName,
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: Constants.plusButtonPointSize, weight: .medium))
        button.setImage(image, for: .normal)
        button.layer.shadowRadius = Constants.plusButtonshadowRadius
        button.layer.shadowOpacity = Constants.plusButtonshadowOpacity
        button.layer.cornerRadius = Constants.plusButtonCornerRadius
        button.layer.shadowOffset = Constants.plusButtonshadowOffset
        button.layer.shadowColor = Colors.colorBlue.cgColor
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
        presenter.viewDidLoad()
    }
}

////MARK: - MainViewController private
//
//private extension MainViewController {
//
//    private func saveAll() {
//        do {
//            //            try presenter.todoItems.saveTodoItems(to: "SavedJsonItems", with: .json)
//
//        } catch {
//        }
//
//    }
//}

//MARK: - TodoDoneUIViewdelegate

extension MainViewController: TodoDoneUIViewdelegate {
    func showIsDone(done: Bool) {
        self.showisDone = done
        UIView.transition(with: tableView, duration: Constants.showDoneAnimationDuration, options: .transitionFlipFromLeft, animations: {self.tableView.reloadData()
        }, completion: nil)
    }
}


//MARK: -  UITableViewDelegate,UITableViewDataSource

extension MainViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showisDone {
            return presenter.getAllItemsCount() + 1
        } else {
            return presenter.getAllItems().filter({$0.isDone != true}).count+1
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row != tableView.numberOfRows(inSection: indexPath.section) - 1 {
            var todomodel: TodoItem?
            if showisDone {
                todomodel = presenter.getAllItems()[indexPath.row]
            } else {
                todomodel = presenter.getAllItems().filter({$0.isDone != true})[indexPath.row]
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cell1Id, for: indexPath) as! TodoTableViewCell
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
            cell.chevron.alpha = 1
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: Constants.cell2Id, for: indexPath) as! CreateNewTaskTableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            presenter.presentViewWithNewTask()
        } else {
            var todomodel: TodoItem?
            if showisDone {
                todomodel = presenter.getAllItems()[indexPath.row]
            } else {
                todomodel = presenter.getAllItems().filter({$0.isDone != true})[indexPath.row]
            }
            if let todomodel {
                presenter.presentViewWith(id: todomodel.id)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row != tableView.numberOfRows(inSection: indexPath.section) - 1 {
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
                
                if let todomodel = self.getTodoItem(parameter: self.showisDone, path: indexPath) {
                    self.presenter.removeTodo(item: todomodel)
                    // self.tableView.reloadData()
                    completionHandler(true)
                }
            }
            
            deleteAction.image = UIImage(systemName: Constants.trashFillImageName)
            deleteAction.backgroundColor = Colors.colorRed.value
            let info = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
                if let todomodel = self.getTodoItem(parameter: self.showisDone, path: indexPath){
                    self.presenter.presentViewWith(id: todomodel.id)
                }
                completionHandler(true)
            }
            info.image = UIImage(named: Constants.iconInfoImageName)
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
                action.image = UIImage(named: Constants.iconActionRadioButtonImageName)
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
            todomodel = self.presenter.getAllItems()
        } else {
            todomodel = self.presenter.getAllItems().filter({$0.isDone != true})
        }
        var newItem =  todomodel.first(where: {$0.id == id})
        let newItem2 = presenter.getAllItems().filter({$0.isDone != true}).firstIndex(where: {$0.id == id})
        let value = todomodel.first(where: {$0.id == id})!.isDone
        
        newItem?.setDone(flag: !value)
        presenter.addItem(item: newItem!)
        presenter.updateDone(item:  newItem!)
        //saveAll()
        
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
    }
}

// MARK: TableView Preview

extension MainViewController {
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let previewProvider: () -> UIViewController? = {
            if indexPath.row != tableView.numberOfRows(inSection: indexPath.section) - 1  {
                if let todomodel = self.getTodoItem(parameter: self.showisDone, path: indexPath){
                    var newVc = UINavigationController(rootViewController: self.presenter.assemblyWith(item: todomodel))
                    return newVc
                }
            }
            return nil
        }
        
        let actionsProvider: ([UIMenuElement]) -> UIMenu? = { _ in
            
            let editAction = UIAction(title: NSLocalizedString("task.edit", comment: "edit task"), image: UIImage(systemName: Constants.editIconImageName)) { [weak self] _ in
                
                if let todomodel = self?.getTodoItem(parameter: self!.showisDone, path: indexPath){
                    let newVc = UINavigationController(rootViewController: (self?.presenter.assemblyWith(item: todomodel))!) //(self?.presenter.assembler.createTodoViewController(with: todomodel))!)
                    newVc.transitioningDelegate = self
                    self?.navigationController?.present(newVc, animated: true)
                }
            }
            
            let deleteAction = UIAction(title: NSLocalizedString("task.remove", comment: "remove task"), image: UIImage(systemName: Constants.trashFillImageName), attributes: .destructive) { [weak self] _ in
                
                if let todomodel = self?.getTodoItem(parameter: self!.showisDone, path: indexPath) {
                    self?.presenter.removeTodo(item: todomodel)
                    //  self?.tableView.reloadData()
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

// MARK: - TableView CornerRadius

extension MainViewController {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let cornerRadius = Constants.tableViewCornerRadius
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
}
