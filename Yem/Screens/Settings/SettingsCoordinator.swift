//
//  SettingsCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 03/04/2024.
//

import LifetimeTracker
import UIKit

final class SettingsCoordinator: Destination {
    weak var parentCoordinator: Destination?
    let viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init()
#if DEBUG
        trackLifetime()
#endif
    }

    override func render() -> UIViewController {
        let controller = SettingsVC(viewModel: viewModel, coordinator: self)
        controller.destination = self
        controller.hidesBottomBarWhenPushed = true
        return controller
    }

    // MARK: Alerts

    func presentAboutAppAlert() {
        let title = "About this app"
        let message = "Yem is an app created for portfolio and educational purposes by Adam Zapiór. You can check out more of my projects and GitHub under the username @adamzapior"
        let alertVC = ValidationAlertVC(title: title, message: message)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve

        navigator?.presentAlert(alertVC)
    }

    func presentLogoutAlert() {
        let title = "Are you sure?"
        let message = "Do you want to logout from app?"

        let alertVC = DualOptionAlertVC(title: title, message: message) {
            Task {
                await self.viewModel.signOut()
                NotificationCenter.default.post(name: NSNotification.Name("ResetApplication"), object: nil)
            }
        } cancelAction: {
            self.navigator?.dismissAlert()
        }
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve

        navigator?.presentAlert(alertVC)
    }
    
    // MARK: Navigation

    func presentSystemSettings() {
        navigator?.presentSystemSettings()
    }
}

#if DEBUG
extension SettingsCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
