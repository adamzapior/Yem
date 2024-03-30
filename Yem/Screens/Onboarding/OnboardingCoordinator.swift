//
//  OnboardingCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import Foundation
import UIKit
import LifetimeTracker

final class OnboardingCoordinator: ChildCoordinator {
    var viewControllerRef: UIViewController?
    var navigationController: UINavigationController

    var parentCoordinator: AppCoordinator?
    let authManager: AuthenticationManager
    let viewModel: OnboardingVM
        
    init(navigationController: UINavigationController, parentCoordinator: AppCoordinator? = nil, authManager: AuthenticationManager, viewModel: OnboardingVM) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.authManager = authManager
        self.viewModel = viewModel
#if DEBUG
        trackLifetime()
#endif
    }
    
    func start(animated: Bool) {
        let onboardingVC = UnloggedOnboardingVC(viewModel: viewModel, coordinator: self)
        onboardingVC.viewModel = viewModel
        
        viewControllerRef = onboardingVC

        navigationController.customPushViewController(viewController: onboardingVC)
    }
    
    func isNavigationBarHidden(value: Bool) {
        self.navigationController.setNavigationBarHidden(value, animated: false)
    }
    
    func coordinatorDidFinish() {
//        parentCoordinator?.logisterFinished(user: User(), animated: true)
        
        if let viewController = viewControllerRef as? DisposableViewController {
            viewController.cleanUp()
        }

        parentCoordinator?.childDidFinish(self)
        viewControllerRef = nil
        parentCoordinator = nil
        
    }
    
    func registerFinished() {
        parentCoordinator?.logisterFinished(user: User(), animated: true)

    }
    
    func pushVC(for route: OnboardingRoute) {
        self.isNavigationBarHidden(value: false)
        switch route {
        case .login:
            let controller = LoginOnboardingVC(coordinator: self, viewModel: viewModel)
            viewControllerRef = controller
            navigationController.customPushViewController(viewController: controller)
//            navigationController.pushViewController(controller, animated: true)
        case .register:
            let controller = RegisterOnboardingVC(coordinator: self, viewModel: viewModel)
            viewControllerRef = controller
            navigationController.customPushViewController(viewController: controller)
        case .resetPassword:
            let controller = ResetPasswordVC(coordinator: self, viewModel: viewModel)
            navigationController.pushViewController(controller, animated: true)
        case .privacyPolicy:
            break
        }
    }
}

enum OnboardingRoute {
    case login
    case register
    case resetPassword
    case privacyPolicy
}

#if DEBUG
extension OnboardingCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
