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
    let authManager: AuthenticationManager
    let dataRepository: DataRepository
    lazy var viewModel = OnboardingVM(authManager: authManager)
    weak var parentCoordinator: AppCoordinator?

    init(authManager: AuthenticationManager, dataRepository: DataRepository) {
        self.authManager = authManager
        self.dataRepository = dataRepository
        super.init()
#if DEBUG
        trackLifetime()
#endif
    }

    override func render() -> UIViewController {
        let controller = UnloggedOnboardingVC(viewModel: viewModel, coordinator: self)
        controller.destination = self
//        navigator?.setNavigationBarHidden()
        return controller
    }

    func navigateTo(_ route: OnboardingRoute) {
        switch route {
        case .login:
            let controller = LoginOnboardingVC(coordinator: self, viewModel: viewModel)
            navigator?.presentScreen(controller)
        case .register:
            let controller = RegisterOnboardingVC(coordinator: self, viewModel: viewModel)
            navigator?.presentScreen(controller)
        case .resetPassword:
            let controller = ResetPasswordVC(coordinator: self, viewModel: viewModel)
            navigator?.presentScreen(controller)
        case .privacyPolicy:
            break
        }
    }

    func navigateToApp(user: UserModel) {
        let tabBarCoordinator = TabBarCoordinator(currentUser: user, dataRepository: dataRepository, authManager: authManager)
        tabBarCoordinator.parentCoordinator = parentCoordinator

        let tabBarAdapter = TabBarCoordinatorAdapter(coordinator: tabBarCoordinator)

        navigator?.setNavigationBarHidden()
        navigator?.changeRoot(screen: tabBarAdapter)
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
