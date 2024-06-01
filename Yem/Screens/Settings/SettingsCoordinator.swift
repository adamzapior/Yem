//
//  SettingsCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 03/04/2024.
//

import LifetimeTracker
import UIKit

final class SettingsCoordinator: Destination {
    weak var parentCoordinator: RecipesListCoordinator?
    let viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init()
#if DEBUG
        trackLifetime()
#endif
    }

    override func render() -> UIViewController {
        let settingsController = SettingsVC(viewModel: viewModel, coordinator: self)
//        settingsController.viewModel = viewModel
        return settingsController
    }

    // MARK: Navigation

    func presentLogoutAlert() {
        let title = "Are you sure?"
        let message = "Do you want to logout from app?"

        let alertVC = DualOptionAlertVC(title: title, message: message) {
            Task {
                await self.viewModel.signOut()

//                self.completeLogout()
            }
            self.resetApplicationToInitialState()
//            self.navigator?.clearAllViewControllers()
//            self.navigator?.changeRoot(screen: AppCoordinator())

        } cancelAction: {
            self.navigator?.dismissAlert()
//            self.coordinatorDidFinish()
        }

        navigator?.present(alert: alertVC)
    }
    
    
    
    func resetApplicationToInitialState() {
        print(parentCoordinator.debugDescription)
        parentCoordinator?.resetApplication()
        }
    

}

#if DEBUG
extension SettingsCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
