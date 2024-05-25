//
//  OnboardingVM.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import Combine
import Foundation
import LifetimeTracker

protocol LoginOnboardingDelegate: AnyObject {
    func showAlert()
}

final class OnboardingVM {
    weak var delegeteLoginOnb: LoginOnboardingDelegate?
    var authManager: AuthenticationManager
    
    @Published
    var user: UserModel?

    @Published
    var userID: UUID = .init()

    @Published
    var login: String = ""

    @Published
    var password: String = ""

    @Published
    var isCheckboxValidation: Bool = false

    init(authManager: AuthenticationManager) {
        self.authManager = authManager
#if DEBUG
        trackLifetime()
#endif
    }
    
    func loginUser(email: String, password: String) async throws -> UserModel {
        do {
            let userModel = try await authManager.loginUser(email: email, password: password)
            user = userModel
            return userModel
        } catch {
            print(error)
            throw error
        }
    }

    func createUser(email: String, password: String) async throws -> UserModel {
        do {
            let userModel = try await authManager.createUser(email: email, password: password)
            user = userModel
            return userModel
        } catch {
            print(error)
            throw error
        }
    }
}

extension OnboardingVM: LoginOnboardingDelegate {
    func showAlert() {
        DispatchQueue.main.async { [weak self] in
            self?.delegeteLoginOnb?.showAlert()
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
