import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let viewController = creatViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
    
    private func creatViewController() -> UIViewController {
        let isEnabled = UserDefaults.standard.bool(forKey: Constants.firstEnabledUserDefaultsKey)
        
        if isEnabled {
            return TabBarController()
        } else {
            let pagesFactory = PageViewControllerFactory()
            let pageViewController = PageViewController(pagesFactory: pagesFactory)
            return pageViewController
        }
    }
}

