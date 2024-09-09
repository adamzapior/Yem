//
//  SplashScreenCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 08/06/2024.
//

import FirebaseAuth
import LifetimeTracker
import UIKit

final class SplashCoordinator: Destination {
    weak var parentCoordinator: AppCoordinator?

    override init() {
        super.init()
        #if DEBUG
            trackLifetime()
        #endif
    }

    override func render() -> UIViewController {
        let viewModel = SplashViewModel(coordinator: self)
        let controller = SplashScreenViewController(viewModel: viewModel)
        controller.destination = self
        return controller
    }

    func navigateFromSplash(isLoggedIn: Bool, user: UserModel?) {
        if isLoggedIn {
            parentCoordinator?.navigateFromSplashVc(isLoggedIn: true, user: user)
        } else {
            parentCoordinator?.navigateFromSplashVc(isLoggedIn: false)
        }
    }
}

final class SplashScreenViewController: UIViewController {
    var viewModel: SplashViewModel?

    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        #if DEBUG
            trackLifetime()
        #endif
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.viewModel?.handleSplashScreen()
        }
    }
}

final class SplashViewModel {
    weak var coordinator: SplashCoordinator?

    init(coordinator: SplashCoordinator) {
        self.coordinator = coordinator
        #if DEBUG
            trackLifetime()
        #endif
    }

    private func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }

    private func currentUser() -> UserModel? {
        if let firebaseUser = Auth.auth().currentUser {
            return UserModel(user: firebaseUser)
        }
        return nil
    }

    func handleSplashScreen() {
        let isLoggedIn = isUserLoggedIn()
        let user = isLoggedIn ? currentUser() : nil
        coordinator?.navigateFromSplash(isLoggedIn: isLoggedIn, user: user)
    }
}

// MARK: - LifetimeTracker


#if DEBUG
    extension SplashCoordinator: LifetimeTrackable {
        class var lifetimeConfiguration: LifetimeConfiguration {
            return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
        }
    }
#endif
