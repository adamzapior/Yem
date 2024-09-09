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

extension OnboardingCoordinator {
    enum OnboardingRoute {
        case login
        case register
        case resetPassword
        case privacyPolicy
    }

    enum OnboardingAlertType {
        case loginError
        case registerError
        case resetPasswordError
    }

    typealias Route = OnboardingRoute
    typealias AlertType = OnboardingAlertType
}

final class OnboardingCoordinator: Destination {
    weak var parentCoordinator: AppCoordinator?

    private let authManager: AuthenticationManager
    private let dataRepository: DataRepository
    private let localFileManager: LocalFileManagerProtocol
    private let imageFetcherManager: ImageFetcherManagerProtocol
    private let viewModel: OnboardingVM

    init(
        authManager: AuthenticationManager,
        dataRepository: DataRepository,
        localFileManager: LocalFileManagerProtocol,
        imageFetcherManager: ImageFetcherManagerProtocol
    ) {
        self.authManager = authManager
        self.dataRepository = dataRepository
        self.localFileManager = localFileManager
        self.imageFetcherManager = imageFetcherManager
        self.viewModel = OnboardingVM(authManager: authManager)
        super.init()
#if DEBUG
        trackLifetime()
#endif
    }

    override func render() -> UIViewController {
        let controller = UnloggedOnboardingVC(viewModel: viewModel, coordinator: self)
        controller.destination = self
        return controller
    }

    func navigateTo(_ route: Route) {
        let viewModel = viewModel
        switch route {
        case .login:
            let controller = LoginOnboardingVC(coordinator: self, viewModel: viewModel)
            navigator?.presentScreen(controller, isAnimated: true)
        case .register:
            let controller = RegisterOnboardingVC(coordinator: self, viewModel: viewModel)
            navigator?.presentScreen(controller, isAnimated: true)
        case .resetPassword:
            let controller = ResetPasswordVC(coordinator: self, viewModel: viewModel)
            navigator?.presentScreen(controller)
        case .privacyPolicy:
            break
        }
    }

    func navigateToApp() {
        guard let user = viewModel.user else { return }
        
        let tabBarCoordinator = TabBarCoordinator(
            currentUser: user,
            dataRepository: dataRepository,
            authManager: authManager,
            localFileManager: localFileManager,
            imageFetcherManager: imageFetcherManager
        )
        tabBarCoordinator.parentCoordinator = parentCoordinator

        let tabBarAdapter = TabBarCoordinatorAdapter(coordinator: tabBarCoordinator)

        navigator?.setNavigationBarHidden()
        navigator?.changeRoot(screen: tabBarAdapter)
    }

    func presentAlert(_ type: AlertType, title: String, message: String) {
        switch type {
        case .loginError:
            let alertVC = ValidationAlertVC(title: title, message: message)
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            navigator?.presentAlert(alertVC)
        case .registerError:
            let alertVC = ValidationAlertVC(title: title, message: message)
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            navigator?.presentAlert(alertVC)
        case .resetPasswordError:
            let alertVC = ValidationAlertVC(title: title,
                                            message: message,
                                            dismissCompletion: {
                                                self.pop()
                                            })
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
extension OnboardingCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
