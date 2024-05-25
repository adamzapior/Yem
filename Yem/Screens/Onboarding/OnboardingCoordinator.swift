//
//  OnboardingCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import FirebaseAuth
import Foundation
import LifetimeTracker
import UIKit

final class OnboardingCoordinator: Destination {
    override func render() -> UIViewController {
        let onboardingVC = UnloggedOnboardingVC(viewModel: viewModel, coordinator: self)
        navigator?.setNavigationBarHidden()
        return onboardingVC
    }

    var authManager: AuthenticationManager
    lazy var viewModel = OnboardingVM(authManager: authManager)

    init(authManager: AuthenticationManager) {
        self.authManager = authManager
        super.init()
#if DEBUG
        trackLifetime()
#endif
        
    }
    
    func navigateToLogin() {
        print("navigate to login")
        navigator?.goTo(screen: OnboardingLoginCoordinator(authManager: authManager, viewModel: viewModel))
    }

//    func start(animated: Bool) {
//        let onboardingVC = UnloggedOnboardingVC(viewModel: viewModel, coordinator: self)
//        viewControllerRef = onboardingVC
//        navigationController.customPushViewController(viewController: onboardingVC)
//    }

//    func coordinatorDidFinish(user: UserModel) {
//        parentCoordinator?.logisterFinished(user: user, animated: true)
//
//        if let viewController = viewControllerRef as? DisposableViewController {
//            viewController.cleanUp()
//        }
//
//        parentCoordinator?.childDidFinish(self)
//        viewControllerRef = nil
//        parentCoordinator = nil
//    }

//    func registerFinished(user: UserModel) {
    ////        coordinatorDidFinish(user: user)
//        parentCoordinator?.logisterFinished(user: user, animated: true)
//    }
//
//    func navigateToLogin(navigationDirection: UINavigationController.VCTransition = .fromBottom) {
//        let viewModel = viewModel
//        let loginViewController = LoginOnboardingVC(coordinator: self, viewModel: viewModel)
//
//
//        viewControllerRef = loginViewController
//        navigationController.customPushViewController(viewController: loginViewController, direction: navigationDirection)
//    }
//
//    func pushVC(for route: OnboardingRoute) {
//        isNavigationBarHidden(value: true)
//        switch route {
//        case .login: break
//
//        case .register:
//            let controller = RegisterOnboardingVC(coordinator: self, viewModel: viewModel)
//            viewControllerRef = controller
//            navigationController.customPushViewController(viewController: controller)
//        case .resetPassword:
//            let controller = ResetPasswordVC(coordinator: self, viewModel: viewModel)
//            navigationController.pushViewController(controller, animated: true)
//        case .privacyPolicy:
//            break
//        }
//    }
}

final class OnboardingLoginCoordinator: Destination {
    override func render() -> UIViewController {
        let onboardingVC = LoginOnboardingVC(coordinator: self, viewModel: viewModel)
        navigator?.setNavigationBarHidden()
        print("render")
        return onboardingVC
    }

    var authManager: AuthenticationManager
    var viewModel: OnboardingVM

    init(authManager: AuthenticationManager, viewModel: OnboardingVM) {
        self.authManager = authManager
        self.viewModel = viewModel
        super.init()
//#if DEBUG
//        trackLifetime()
//#endif
    }
    

    
    func navigateToApp(user: UserModel) {
        navigator?.changeRoot(screen: TabBarDestination(currentUser: user, dataRepository: DataRepository(), authManager: authManager))
    }
    
    
}

enum OnboardingRoute {
    case login
    case register
    case resetPassword
    case privacyPolicy
}

// protocol OnboardingParentCoordinator: AnyObject {
//    func logisterFinished(user: UserModel, animated: Bool)
//    func childDidFinish(_ child: ChildCoordinator)}
//
// extension OnboardingCoordinator: OnboardingParentCoordinator {
//    func logisterFinished(user: UserModel, animated: Bool) {
//        parentCoordinator?.logisterFinished(user: user, animated: animated)
//    }
//
//    func childDidFinish(_ child: ChildCoordinator) {
//        parentCoordinator?.childDidFinish(child)
//    }
// }

#if DEBUG
extension OnboardingCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
