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
        let viewModel = OnboardingVM()
        let onboardingVC = UnloggedOnboardingVC(viewModel: viewModel, coordinator: self)
        onboardingVC.viewModel = viewModel
        
        viewControllerRef = onboardingVC

        navigationController.customPushViewController(viewController: onboardingVC)
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
}

#if DEBUG
extension OnboardingCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
