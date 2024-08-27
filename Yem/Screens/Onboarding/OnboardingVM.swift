//
//  OnboardingVM.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import Foundation
import LifetimeTracker

protocol LoginOnboardingDelegate: AnyObject {
    func showLoginErrorAlert()
}

protocol RegisterOnboardingDelegate: AnyObject {
    func showRegisterErrorAlert()
}

final class OnboardingVM {
    weak var delegeteLoginOnb: LoginOnboardingDelegate?
    weak var delegateRegisterOnb: RegisterOnboardingDelegate?

    var authManager: AuthenticationManager

    var user: UserModel?
    
    var userID: UUID = .init()
    
    var login: String = ""
    
    var password: String = ""
    
    var validationError: String = ""

    init(authManager: AuthenticationManager) {
        self.authManager = authManager
#if DEBUG
        trackLifetime()
#endif
    }

    func loginUser(email: String, password: String) async throws -> UserModel? {
        do {
            let userModel = try await authManager.loginUser(email: email, password: password)
            user = userModel
            return userModel
        } catch {
            handleError(error)
            showLoginErrorAlert()
            return nil
        }
    }

    func createUser(email: String, password: String) async throws -> UserModel? {
        do {
            let userModel = try await authManager.createUser(email: email, password: password)
            user = userModel
            return userModel
        } catch {
            handleError(error)
            showRegisterErrorAlert()
            return nil
        }
    }

    private func handleError(_ error: Error) {
        validationError = error.localizedDescription
    }
}

extension OnboardingVM: LoginOnboardingDelegate {
    func showLoginErrorAlert() {
        DispatchQueue.main.async { [weak self] in
            self?.delegeteLoginOnb?.showLoginErrorAlert()
        }
    }
}

extension OnboardingVM: RegisterOnboardingDelegate {
    func showRegisterErrorAlert() {
        DispatchQueue.main.async { [weak self] in
            self?.delegateRegisterOnb?.showRegisterErrorAlert()
        }
    }
}

#if DEBUG
extension OnboardingVM: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewModels")
    }
}
#endif
