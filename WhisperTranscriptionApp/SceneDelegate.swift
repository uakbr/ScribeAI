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
        Task {
            if isFirstLaunch() {
                presentOnboardingInterface()
            } else if await isUserAuthenticated() {
                presentMainInterface()
            } else {
                presentLoginInterface()
            }
        }
        
        window?.makeKeyAndVisible()
    }

    // MARK: - Authentication Check
    private func isUserAuthenticated() async -> Bool {
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            return session?.user != nil
        } catch {
            print("Authentication check failed: \(error)")
            return false
        }
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
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            return true
        }
        return false
    }

    private func presentOnboardingInterface() {
        let onboardingVC = OnboardingViewController()
        window?.rootViewController = UINavigationController(rootViewController: onboardingVC)
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