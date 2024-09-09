//
//  SettingsCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 03/04/2024.
//

import LifetimeTracker
import UIKit

extension SettingsCoordinator {
    enum SettingsRoute {
        case logout
        case systemSettings
    }

    enum SettingsAlertType {
        case logout
        case aboutApp
    }

    typealias Route = SettingsRoute
    typealias AlertType = SettingsAlertType
}

final class SettingsCoordinator: Destination {
    weak var parentCoordinator: Destination?

    private let authManager: AuthenticationManager
    private let viewModel: SettingsVM

    init(authManager: AuthenticationManager) {
        self.authManager = authManager
        self.viewModel = SettingsVM(authManager: authManager)
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

    func navigateTo(_ route: Route) {
        switch route {
        case .logout:
            Task {
                await self.viewModel.signOut()
                NotificationCenter.default.post(name: NSNotification.Name("ResetApplication"), object: nil)
            }
        case .systemSettings:
            navigator?.presentSystemSettings()
        }
    }

    func present(_ alert: AlertType, title: String, message: String) {
        switch alert {
        case .logout:
            let alertVC = DualOptionAlertVC(title: title, message: message) {
                self.navigateTo(.logout)
            } cancelAction: {
                self.navigator?.dismissAlert()
            }
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            navigator?.presentAlert(alertVC)
        case .aboutApp:
            let alertVC = ValidationAlertVC(title: title, message: message)
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            navigator?.presentAlert(alertVC)
        }
    }

    func pop() {
        navigator?.pop()
    }

    func dismissSheet() {
        navigator?.dismissSheet()
    }

    func dismissAlert() {
        navigator?.dismissAlert()
    }
}

// MARK: - LifetimeTracker


#if DEBUG
extension SettingsCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
