import UIKit
import Supabase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        // Determine the initial view controller
        if isFirstLaunch() {
            presentOnboardingInterface()
        } else if isUserAuthenticated() {
            presentMainInterface()
        } else {
            presentLoginInterface()
        }
        
        window?.makeKeyAndVisible()
    }

    // MARK: - Authentication Check
    private func isUserAuthenticated() -> Bool {
        // Check if Supabase session exists and is valid
        if let session = SupabaseManager.shared.client.auth.session, session.user != nil {
            return true
        }
        return false
    }

    // MARK: - Interface Presentation
    private func presentMainInterface() {
        let transcriptionListVC = TranscriptionListViewController()
        let navigationController = UINavigationController(rootViewController: transcriptionListVC)
        window?.rootViewController = navigationController
    }

    private func presentLoginInterface() {
        let loginVC = LoginViewController()
        window?.rootViewController = loginVC
    }

    // MARK: - Onboarding Check
    private func isFirstLaunch() -> Bool {
        let hasLaunchedKey = "hasLaunchedBefore"
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: hasLaunchedKey) {
            return false
        } else {
            userDefaults.set(true, forKey: hasLaunchedKey)
            return true
        }
    }

    private func presentOnboardingInterface() {
        let onboardingVC = OnboardingViewController()
        window?.rootViewController = onboardingVC
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Start background task to keep the app running while minimized
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "RecordingBackgroundTask") {
            // This block is called when time expires
            self.endBackgroundTask()
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // End the background task when the app enters the foreground
        endBackgroundTask()
    }

    // MARK: - Helper Methods
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}