
import UIKit
import TodoItem

protocol IMainAssembly {
    func createMainViewController() -> UIViewController
}

class MainAssembly: IMainAssembly {

    let presenter = MainPresenter()
    func createMainViewController() -> UIViewController {

        let view = MainViewController(presenter: presenter)
        presenter.view = view
        let navController = UINavigationController()
        navController.viewControllers = [view]
        return view
    }
}
