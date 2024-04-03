//
//  SettingsCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 03/04/2024.
//

import LifetimeTracker
import UIKit

final class SettingsCoordinator: ParentCoordinator, ChildCoordinator {
    var parentCoordinator: RecipesListCoordinator?
    var childCoordinators: [Coordinator] = []
    var viewControllerRef: UIViewController?
    var navigationController: UINavigationController

    let viewModel: SettingsViewModel

    init(parentCoordinator: RecipesListCoordinator?, viewControllerRef: UIViewController?, navigationController: UINavigationController, viewModel: SettingsViewModel) {
        self.parentCoordinator = parentCoordinator
        self.viewControllerRef = viewControllerRef
        self.navigationController = navigationController
        self.viewModel = viewModel

#if DEBUG
        trackLifetime()
#endif
    }

    func start(animated: Bool) {
        let settingsController = SettingsVC(viewModel: viewModel, coordinator: self)

        viewControllerRef = settingsController
        navigationController.customPushViewController(viewController: settingsController, direction: .fromRight, transitionType: .moveIn)
    }

    func coordinatorDidFinish() {
        if let viewController = viewControllerRef as? DisposableViewController {
            viewController.cleanUp()
        }

        parentCoordinator?.childDidFinish(self)
        viewControllerRef = nil
        parentCoordinator = nil
    }

    func presentLogoutAlert() {
        let title = "Are you sure?"
        let message = "Do you want to logout from app?"

        let alertVC = DualOptionAlertVC(title: title, message: message) {
            self.viewModel.logoutUser()
            self.coordinatorDidFinish()
            self.popViewController(animated: true)
        } cancelAction: {
            self.coordinatorDidFinish()
        }
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        navigationController.present(alertVC, animated: true, completion: nil)
    }

//    func dismissAlert() {
//        navigationController.dismiss(animated: true)
//    }
//
//    func dismissVC() {
//        navigationController.customPopToRootViewController()
//    }
}

#if DEBUG
extension SettingsCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
