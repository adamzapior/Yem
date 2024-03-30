//
//  AppCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 28/03/2024.
//

import UIKit
import FirebaseAuth
import LifetimeTracker


final class AppCoordinator: NSObject, ParentCoordinator {
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        
#if DEBUG
        trackLifetime()
#endif
    }
    
    func start(animated: Bool) {
           let viewModel = SplashViewModel(coordinator: self)
           let fakeSplashVC = SplashScreenViewController()
           fakeSplashVC.viewModel = viewModel
           navigationController.pushViewController(fakeSplashVC, animated: animated)
       }
    
    func childDidFinish(_ child: Coordinator) {
        if let index = childCoordinators.firstIndex(where: { $0 === child }) {
            print("Removing child coordinator: \(child)")
                 childCoordinators.remove(at: index)
                 print("Current child coordinators: \(childCoordinators)")
        }
    }
    
    // MARK: - nav From
    func navigateFromSplashVc(isLoggedIn: Bool, user: User? = nil) {
        if let user, isLoggedIn {
            navigateToApp(userData: user)
        } else {
            navigateToOnboarding()
        }
    }
    
    // MARK: - nav To
       private func navigateToApp(userData: User) {
           let tabBarCoordinator = TabBarCoordinator(currentUser: userData, coordinator: self)
           tabBarCoordinator.coordinator = self
           navigationController.pushViewController(tabBarCoordinator, animated: true)
       }
       
       private func navigateToOnboarding() {
           let onBoardingCoordinator = OnboardingCoordinator(navigationController: navigationController, authManager: AuthenticationManager.instance, viewModel: OnboardingVM())
           onBoardingCoordinator.parentCoordinator = self
           childCoordinators.append(onBoardingCoordinator)
           onBoardingCoordinator.start(animated: true)
       }
    
    
       
       // MARK: - flow Finished
       func logisterFinished(user: User, animated: Bool) {
           navigateToApp(userData: user)
       }
}


class SplashScreenViewController: UIViewController {

    var viewModel: SplashViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // .. initialize stuff, fetch needed data and do anything needed inside the app ..
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.viewModel.removeSpashScreen()
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
    func isUserConnected() -> Bool {
        return false
    }
    
    
    // MARK: - Navigation
    func removeSpashScreen() {
        coordinator.navigateFromSplashVc(isLoggedIn: isUserConnected(), user: User())
    }
}

struct User {
    let login: String = "Test"
}



#if DEBUG
extension AppCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
