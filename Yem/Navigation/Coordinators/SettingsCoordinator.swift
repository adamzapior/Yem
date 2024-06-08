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

    // MARK: Navigation

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
        navigator?.presentAlert(alertVC)
    }

    func presentSystemSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl)
        else {
            print("DEBUG: Cannot open system settings.")
            return
        }

        DispatchQueue.main.async {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
}

#if DEBUG
extension SettingsCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
