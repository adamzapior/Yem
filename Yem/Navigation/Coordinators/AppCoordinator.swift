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
    lazy var dataRepository = DataRepository()
    
//    lazy var tabBarCoordinator = TabBarCoordinator(currentUser: currentUser()!, dataRepository: dataRepository, authManager: authManager)
//    lazy var tabBarCoordinator: TabBarCoordinator? = TabBarCoordinator(currentUser: currentUser()!, dataRepository: dataRepository, authManager: authManager)
    var tabBarCoordinator: TabBarCoordinator?

    override init() {
        super.init()
#if DEBUG
        trackLifetime()
#endif
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func initializeTabBarCoordinator() {
//        guard let user = currentUser() else {
//            print("User not logged in")
//            return
//        }
//        tabBarCoordinator = TabBarCoordinator(currentUser: user, dataRepository: dataRepository, authManager: authManager)
//        tabBarCoordinator?.parentCoordinator = self
//
//        print("mammmm dosc")
//    }
    
    override func render() -> UIViewController {
        print("Rendering initial view in AppCoordinator")
        let viewModel = SplashViewModel(coordinator: self)
        let fakeSplashVC = SplashScreenViewController()
        fakeSplashVC.viewModel = viewModel

        return fakeSplashVC
    }
    
    func currentUser() -> UserModel? {
        if let firebaseUser = Auth.auth().currentUser {
            print(firebaseUser.email as Any)
            return UserModel(user: firebaseUser)
        }
        
        return nil
    }

    func resetToInitialCoordinator() {
        navigateToOnboarding() // lub inny początkowy flow
    }
    
    // Nav From

    func navigateFromSplashVc(isLoggedIn: Bool, user: UserModel? = nil) {
        if isLoggedIn, let user = user {
            navigateToApp(userData: user)
            print("1")
        } else {
            navigateToOnboarding()
            print("2")
        }
    }

    // Nav to
    
    private func navigateToApp(userData: UserModel) {
//        initializeTabBarCoordinator()
//        navigator?.goTo(screen: TabBarDestination(currentUser: userData, dataRepository: dataRepository, authManager: authManager, parentCoordinator: self))
        let tabBarCoordinator = TabBarCoordinator(currentUser: userData, dataRepository: dataRepository, authManager: authManager)
        tabBarCoordinator.parentCoordinator = self
        self.tabBarCoordinator = tabBarCoordinator // Zapisz referencję do tabBarCoordinator
        let tabBarDestination = TabBarDestination(currentUser: userData, dataRepository: DataRepository(), authManager: authManager, parentCoordinator: self, tabBarCoordinator: tabBarCoordinator)
        navigator?.setNavigationBarHidden() // IMPORTANT!!!
        navigator?.goTo(screen: tabBarDestination)
    }
       
    private func navigateToOnboarding() {
        print("AppCoordinator: Navigating to Onboarding")
        if let navigator = navigator {
            let onboardingCoordinator = OnboardingCoordinator(authManager: authManager)
            onboardingCoordinator.parentCoordinator = self
            navigator.goTo(screen: onboardingCoordinator)
        } else {
            print("AppCoordinator: Navigator is nil")
        }
    }
    
    // MARK: flow Finished

    func logisterFinished(user: UserModel, animated: Bool) {
        navigateToApp(userData: user)
    }
    
    // MARK: - TEST TEST TEST
    
    func resetToInitialView() {
        print("resetToInitialView from AppCoordinator")
                
        tabBarCoordinator?.clearAllNavigators()
        tabBarCoordinator = nil
        
        let initialViewDestination = InitialViewDestination(coordinator: self)
        navigator?.changeRoot(screen: initialViewDestination)
    }
    
    private func renderInitialView() -> UIViewController {
        // Przykład - stwórz i zwróć widok startowy
        let splashViewModel = SplashViewModel(coordinator: self)
        let splashVC = SplashScreenViewController()
        splashVC.viewModel = splashViewModel
        return splashVC
    }
}

final class InitialViewDestination: Destination {
    var coordinator: AppCoordinator

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        super.init()
    }
    
    override func render() -> UIViewController {
        let splashViewModel = SplashViewModel(coordinator: coordinator)
        let splashVC = SplashScreenViewController()
        splashVC.viewModel = splashViewModel
        return splashVC
    }
}

// MARK: - Splash screen implementation

class SplashScreenViewController: UIViewController {
    var viewModel: SplashViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG: SplashScreenViewController viewDidLoad()")
        DispatchQueue.main.async {
            self.viewModel.removeSplashScreen()
        }
    }
}

class SplashViewModel {
    var coordinator: AppCoordinator
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
    
    func isUserLoggedIn() -> Bool {
        let result = Auth.auth().currentUser != nil
        return result
    }
    
    func currentUser() -> UserModel? {
        if let firebaseUser = Auth.auth().currentUser {
            print(firebaseUser.email as Any)
            return UserModel(user: firebaseUser)
        }
        
        return nil
    }
    
    func removeSplashScreen() {
        if isUserLoggedIn() {
            print("SplashViewModel: User is logged in, navigating to app")
            coordinator.navigateFromSplashVc(isLoggedIn: true, user: currentUser())
        } else {
            print("SplashViewModel: User is not logged in, navigating to onboarding")
            coordinator.navigateFromSplashVc(isLoggedIn: false)
        }
    }
}

#if DEBUG
extension SplashScreenViewController: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "SplashScreenViewController")
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
