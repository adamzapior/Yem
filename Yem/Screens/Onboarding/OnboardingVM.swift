//
//  OnboardingVM.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import Combine
import Foundation
import LifetimeTracker

final class OnboardingVM {
    private let authManager: AuthenticationManager

    var user: UserModel?

    @Published var login: String = ""

    @Published var password: String = ""

    let inputEvent = PassthroughSubject<Input, Never>()

    var inputPublisher: AnyPublisher<Input, Never> {
        inputEvent.eraseToAnyPublisher()
    }

    /// ViewModel publisher store
    var outputPublisher: AnyPublisher<Output, Never> {
        outputEvent.eraseToAnyPublisher()
    }

    /// ViewModel publisher
    private let outputEvent = PassthroughSubject<Output, Never>()

    private var cancellables = Set<AnyCancellable>()

    init(authManager: AuthenticationManager) {
        self.authManager = authManager

        observeLogin()
        observeInput()

#if DEBUG
        trackLifetime()
#endif
    }

    // MARK: - Auth methods

    func tryToLogin() async throws -> UserModel? {
        do {
            let userModel = try await authManager.loginUser(email: login, password: password)
            user = userModel
            outputEvent.send(.loginSuccesed)
            return userModel
        } catch {
            DispatchQueue.main.async { [unowned self] in /// The VM is not allocated before logging in after the application and is used by all onboarding screens
                self.outputEvent.send(.showErrorAlert(.loginFailed, message: error.localizedDescription))
            }
            return nil
        }
    }

    func tryToRegister() async throws -> UserModel? {
        do {
            let userModel = try await authManager.createUser(email: login, password: password)
            user = userModel
            return userModel
        } catch {
            DispatchQueue.main.async { [unowned self] in
                self.outputEvent.send(.showErrorAlert(.registerFailed, message: error.localizedDescription))
            }
            return nil
        }
    }

    func tryResetPassword() async throws {
        do {
            try await authManager.resetPassword(email: login)
            DispatchQueue.main.async { [unowned self] in
                outputEvent.send(.showErrorAlert(.resetPasswordSuccesed, message: "Check your e-mail"))
            }
        } catch {
            DispatchQueue.main.async { [unowned self] in
                self.outputEvent.send(.showErrorAlert(.resetPasswordFailed, message: error.localizedDescription))
            }
        }
    }
}

// MARK: - Observed properties

extension OnboardingVM {
    private func observeLogin() {
        $login
            .sink { value in
                let filteredValue = value.trimmingCharacters(in: .whitespaces)
                if filteredValue != value {
                    self.login = filteredValue
                } else {
                    DispatchQueue.main.async { [unowned self] in
                        self.outputEvent.send(.updateField(.login(value: filteredValue)))
                    }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Observed Input

extension OnboardingVM {
    private func observeInput() {
        inputPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] event in
                self.handleInput(event: event)
            }.store(in: &cancellables)
    }

    private func handleInput(event: Input) {
        switch event {
        case .sendString(let type):
            switch type {
            case .login(value: let value):
                login = value
            case .password(value: let value):
                password = value
            }
        }
    }
}

// MARK: - Input & Output Definitions

extension OnboardingVM {
    enum Input {
        case sendString(LoginField)
    }

    enum Output {
        case loginSuccesed
        case updateField(LoginField)
        case showErrorAlert(_ type: AlertType, message: String)
    }

    enum AlertType {
        case loginFailed
        case registerFailed
        case resetPasswordFailed
        case resetPasswordSuccesed
    }

    enum LoginField {
        case login(value: String)
        case password(value: String)
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension OnboardingVM: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewModels")
    }
}
#endif
