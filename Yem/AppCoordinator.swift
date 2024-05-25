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
    
    lazy var tabBarCoordinator = TabBarCoordinator(currentUser: currentUser()!, dataRepository: dataRepository, authManager: authManager)
    
    override init() {
        super.init()
#if DEBUG
        trackLifetime()
#endif
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func render() -> UIViewController {
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
//
//    
//    func start(animated: Bool) {
//        let viewModel = SplashViewModel(coordinator: self)
//        let fakeSplashVC = SplashScreenViewController()
//        fakeSplashVC.viewModel = viewModel
////        navigationController.pushViewController(fakeSplashVC, animated: animated)
//    }
    
    func resetToInitialCoordinator() {
        // Usuń wszystkie child coordinators
//        navigator?.popUpTo(predicate: { d in
//            d == self
//        })
//        tabBarCoordinator.resetChildCoordinators()
        
        // Następnie zainicjuj flow, który chcesz rozpocząć
        navigateToOnboarding() // lub inny początkowy flow
    }
    
    // MARK: - nav From

    func navigateFromSplashVc(isLoggedIn: Bool, user: UserModel? = nil) {
        if isLoggedIn, let user = user {
            navigateToApp(userData: user)
            print("1")
        } else {
            navigateToOnboarding()
            print("2")
        }
    }

    // MARK: - nav To

    private func navigateToApp(userData: UserModel) {
        navigator?.goTo(screen: TabBarDestination(currentUser: userData, dataRepository: dataRepository, authManager: authManager))
//        navigationController.pushViewController(tabBarCoordinator, animated: true)
    }
       
    private func navigateToOnboarding() {
        print(navigator.debugDescription)
        navigator?.goTo(screen: OnboardingCoordinator(authManager: authManager))
    }
    
    // MARK: - flow Finished

    func logisterFinished(user: UserModel, animated: Bool) {
        navigateToApp(userData: user)
    }
}

class SplashScreenViewController: UIViewController {
    var viewModel: SplashViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("xd")
        DispatchQueue.main.async {
            self.viewModel.removeSplashScreen()
        }
    }
}

class SplashViewModel {
    // MARK: - Variables

    var coordinator: AppCoordinator
    
    // MARK: - init

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
    
    // MARK: - Functions
        
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
    
    // MARK: - Navigation

    func removeSplashScreen() {
        if isUserLoggedIn() {
            coordinator.navigateFromSplashVc(isLoggedIn: true, user: currentUser())
        } else {
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
