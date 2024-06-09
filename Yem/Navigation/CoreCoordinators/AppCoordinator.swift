//
//  AppCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 28/03/2024.
//

import FirebaseAuth
import LifetimeTracker
import UIKit

final class AppCoordinator: Destination {
    let authManager = AuthenticationManager()
    let dataRepository = DataRepository()

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(resetApplication), name: NSNotification.Name("ResetApplication"), object: nil)
#if DEBUG
        trackLifetime()
#endif
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func render() -> UIViewController {
        let splashCoordinator = SplashCoordinator()
        splashCoordinator.parentCoordinator = self
        return splashCoordinator.render()
    }

    func navigateFromSplashVc(isLoggedIn: Bool, user: UserModel? = nil) {
        if isLoggedIn, let user = user {
            navigateToApp(userData: user)
        } else {
            navigateToOnboarding()
        }
    }

    private func navigateToApp(userData: UserModel) {
        let tabBarCoordinator = TabBarCoordinator(currentUser: userData, dataRepository: dataRepository, authManager: authManager)
        tabBarCoordinator.parentCoordinator = self

        let tabBarAdapter = TabBarCoordinatorAdapter(coordinator: tabBarCoordinator)

        navigator?.setNavigationBarHidden()
        navigator?.changeRoot(screen: tabBarAdapter)
    }

    private func navigateToOnboarding() {
        let onboardingCoordinator = OnboardingCoordinator(authManager: authManager, dataRepository: dataRepository)
        onboardingCoordinator.parentCoordinator = self
        navigator?.changeRoot(screen: onboardingCoordinator)
    }

    // MARK: - Logout Management

    @objc func resetApplication() {
        print("DEBUG: AppCoordinator - resetting application to initial state")
        DispatchQueue.main.async {
            self.resetToInitialView()
        }
    }

    func resetToInitialView() {
        print("DEBUG: resetToInitialView method from AppCoordinator called")
        navigator?.clearAllViewControllers()

        let splashCoordinator = SplashCoordinator()
        splashCoordinator.parentCoordinator = self
        navigator?.changeRoot(screen: splashCoordinator)
    }
}

#if DEBUG
extension SplashScreenViewController: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "SplashScreen")
    }
}
#endif

#if DEBUG
extension SplashViewModel: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "SplashScreen")
    }
}
#endif

#if DEBUG
extension AppCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
