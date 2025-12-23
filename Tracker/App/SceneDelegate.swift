import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = selectVC()
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    private func selectVC() -> UIViewController{
        
        let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
        
        if onboardingCompleted {
            return TabBarController()
        } else {
            let onboardingVC = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            onboardingVC.onboardingCompletionHandler = { [weak self] in
                self?.switchToTabBar()
            }
            return onboardingVC
        }
    }
    
    private func switchToTabBar() {
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()

        let transition = CATransition()
        transition.type = .fade
        transition.duration = 0.3
        window?.layer.add(transition, forKey: kCATransition)
    }
}
