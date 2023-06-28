import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        let mainView = MainViewController(nibName: nil, bundle: nil)
        let nav1 = UINavigationController()
         nav1.viewControllers = [mainView]
        window?.rootViewController = nav1
        window?.makeKeyAndVisible()
    
        return true
    }
}
