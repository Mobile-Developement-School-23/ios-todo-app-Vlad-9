import UIKit
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let nav1 = UINavigationController()
        let mainView = MainAssembly().createMainViewController()//MainViewController(nibName: nil, bundle: nil)
         nav1.viewControllers = [mainView]
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = nav1
        self.window = window
        window.makeKeyAndVisible()
    }
}
