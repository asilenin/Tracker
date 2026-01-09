import UIKit
import AppMetricaCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Public Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupAppMetrica()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(
            name: "Main",
            sessionRole: connectingSceneSession.role
        )
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }
    
    // MARK: - Private Methods
    private func setupAppMetrica() {
        guard
            let apiKey = Bundle.main.object(
                forInfoDictionaryKey: "AppMetricaAPIKey"
            ) as? String,
            !apiKey.isEmpty
        else {
            assertionFailure("[TrackersViewController]:\(#line)] \(#function) AppMetrica API key not found")
            return
        }
        
        if let configuration = AppMetricaConfiguration(apiKey: apiKey) {
            AppMetrica.activate(with: configuration)
        }
    }
}

