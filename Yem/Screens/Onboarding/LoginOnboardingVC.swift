//
//  LoginOnboardingVC.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import Combine
import CombineCocoa
import LifetimeTracker
import SnapKit
import UIKit

final class LoginOnboardingVC: UIViewController {
    private weak var coordinator: OnboardingCoordinator?
    private let viewModel: OnboardingVM

    private var content = UIView()

    private let titleLabel = TextLabel(
        fontStyle: .title2,
        fontWeight: .light,
        textColor: .ui.secondaryText,
        textAlignment: .center
    )
    private let loginLabel = TextLabel(
        fontStyle: .footnote,
        fontWeight: .light,
        textColor: .ui.secondaryText
    )
    private let passwordLabel = TextLabel(
        fontStyle: .footnote,
        fontWeight: .light,
        textColor: .ui.secondaryText
    )

    private let loginTextfield = TextfieldWithIcon(
        iconImage: "person.circle",
        placeholderText: "Enter your e-mail...",
        textColor: .ui.secondaryText
    )
    private let passwordTextfield = TextfieldWithIcon(
        iconImage: "staroflife",
        placeholderText: "Enter your password...",
        textColor: .ui.secondaryText
    )

    private let loginButton = ActionButton(
        title: "Try to login...",
        backgroundColor: .ui.addBackground,
        isShadownOn: true
    )

    private let resetButton = ActionButton(
        title: "Reset password",
        backgroundColor: .ui.cancelBackground,
        isShadownOn: true
    )

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle

    init(coordinator: OnboardingCoordinator, viewModel: OnboardingVM) {
        self.coordinator = coordinator
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
        view.backgroundColor = .systemBackground

        setupUI()
        setupTextfieldBehaviour()
        setupVoiceOverAccessibility()

        observeViewModelEventOutput()
        observeTextfields()
        observeActionButtons()
    }

    private func setupUI() {
        view.addSubview(content)

        content.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(84)
            make.leading.trailing.bottom.equalToSuperview().inset(18)
        }

        content.addSubview(titleLabel)
        content.addSubview(loginLabel)
        content.addSubview(passwordLabel)
        content.addSubview(loginTextfield)
        content.addSubview(passwordTextfield)
        content.addSubview(loginButton)
        content.addSubview(resetButton)

        titleLabel.text = "Login to app"
        loginLabel.text = "Login"
        passwordLabel.text = "Password"

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(18)
            make.centerX.equalToSuperview()
        }

        loginLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        loginTextfield.snp.makeConstraints { make in
            make.top.equalTo(loginLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(64)
        }

        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(loginTextfield.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        passwordTextfield.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(64)
        }

        resetButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextfield.snp.bottom).offset(36)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        loginButton.snp.makeConstraints { make in
            make.top.equalTo(resetButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(12)
        }
    }

    private func setupTextfieldBehaviour() {
        loginTextfield.textField.autocapitalizationType = .none
        passwordTextfield.textField.autocapitalizationType = .none
        passwordTextfield.textField.isSecureTextEntry = true
    }

    private func setupVoiceOverAccessibility() {
        loginTextfield.isAccessibilityElement = true
        loginTextfield.accessibilityLabel = "Login textfield"
        loginTextfield.accessibilityHint = "Enter your e-mail"

        passwordTextfield.isAccessibilityElement = true
        passwordTextfield.accessibilityLabel = "Reset textfield"
        passwordTextfield.accessibilityHint = "Enter your password"

        loginButton.isAccessibilityElement = true
        loginButton.accessibilityLabel = "Login button"
        loginButton.accessibilityHint = "Click this button and try to login"

        resetButton.isAccessibilityElement = true
        resetButton.accessibilityLabel = "Reset password button"
        resetButton.accessibilityHint = "Click this button and go to reset password screen"
    }
}

// MARK: - Observe ViewModel Output & UI actions

extension LoginOnboardingVC {
    private func observeViewModelEventOutput() {
        viewModel.outputPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] event in
                self.handleViewModelOutput(event: event)
            }
            .store(in: &cancellables)
    }

    private func observeTextfields() {
        loginTextfield.textField
            .textPublisher
            .sink { [unowned self] text in
                self.viewModel.inputEvent.send(
                    .sendString(
                        .login(value: text ?? "")
                    )
                )
            }
            .store(in: &cancellables)

        passwordTextfield.textField
            .textPublisher
            .sink { [unowned self] text in
                self.viewModel.inputEvent.send(
                    .sendString(
                        .password(value: text ?? "")
                    )
                )
            }
            .store(in: &cancellables)
    }

    private func observeActionButtons() {
        loginButton
            .tapPublisher
            .sink { [unowned self] in
                self.handleActionButtonEvent(type: .login)
            }
            .store(in: &cancellables)

        resetButton
            .tapPublisher
            .sink { [unowned self] in
                self.handleActionButtonEvent(type: .resetPassword)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Handle Output & UI Actions

extension LoginOnboardingVC {
    private func handleViewModelOutput(event: OnboardingVM.Output) {
        switch event {
        case .loginSuccesed:
            navigateToApp()
        case .updateField(let textField):
            handleUpdateField(for: textField)
        case .showErrorAlert(let alert, message: let message):
            presentAlert(alert, message: message)
        }
    }

    private func handleUpdateField(for field: OnboardingVM.LoginField) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch field {
            case .login(value: let value):
                loginTextfield.textField.text = value
            case .password(value: let value):
                passwordTextfield.textField.text = value
            }
        }
    }

    private func handleActionButtonEvent(type: ButtonType) {
        switch type {
        case .login:
            Task {
                try await viewModel.tryToLogin()
            }
        case .resetPassword:
            navigateToResetPasswordScreen()
        }
    }
}

// MARK: - Navigation

extension LoginOnboardingVC {
    private func navigateToApp() {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.navigateToApp()
        }
    }
    
    private func navigateToResetPasswordScreen() {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.navigateTo(.resetPassword)
        }
    }

    private func presentAlert(_ type: OnboardingVM.AlertType, message: String) {
        DispatchQueue.main.async { [weak self] in
            if type == .loginFailed {
                self?.coordinator?.presentAlert(.loginError, title: "Something went wrong!", message: message)
            }
        }
    }
}

// MARK: - Helper enum

extension LoginOnboardingVC {
    private enum ButtonType {
        case login
        case resetPassword
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension LoginOnboardingVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
