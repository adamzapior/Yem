//
//  LoginOnboardingVC.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import FirebaseAuth
import LifetimeTracker
import SnapKit
import UIKit

final class LoginOnboardingVC: UIViewController {
    weak var coordinator: OnboardingCoordinator?
    let viewModel: OnboardingVM

    var content = UIView()

    let textLabel = TextLabel(
        fontStyle: .title2,
        fontWeight: .light,
        textColor: .ui.secondaryText
    )
    let loginLabel = TextLabel(
        fontStyle: .footnote,
        fontWeight: .light,
        textColor: .ui.secondaryText
    )
    let passwordLabel = TextLabel(
        fontStyle: .footnote,
        fontWeight: .light,
        textColor: .ui.secondaryText
    )

    let loginTextfield = TextfieldWithIcon(
        iconImage: "info",
        placeholderText: "Enter your e-mail...",
        textColor: .ui.secondaryText
    )
    let passwordTextfield = TextfieldWithIcon(
        iconImage: "staroflife",
        placeholderText: "Enter your password...",
        textColor: .ui.secondaryText
    )

    let loginButton = ActionButton(
        title: "Try to login...",
        backgroundColor: .ui.addBackground,
        isShadownOn: true
    )

    let resetButton = ActionButton(
        title: "Reset password",
        backgroundColor: .ui.cancelBackground,
        isShadownOn: true
    )

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
        setupDelegate()
        setupTag()
        setupTextfieldBehaviour()
        setupVoiceOverAccessibility()

        viewModel.delegeteLoginOnb = self
    }

    private func setupUI() {
        view.addSubview(content)

        content.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(84)
            make.leading.trailing.bottom.equalToSuperview().inset(18)
        }

        content.addSubview(textLabel)
        content.addSubview(loginLabel)
        content.addSubview(passwordLabel)
        content.addSubview(loginTextfield)
        content.addSubview(passwordTextfield)
        content.addSubview(loginButton)
        content.addSubview(resetButton)

        textLabel.text = "Login to app"
        loginLabel.text = "Login"
        passwordLabel.text = "Password"

        textLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        loginLabel.snp.makeConstraints { make in
            make.top.equalTo(textLabel.snp.bottom).offset(12)
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
//            make.height.equalTo(42.VAdapted)

            make.height.greaterThanOrEqualTo(42.VAdapted).priority(.high)
            make.height.lessThanOrEqualTo(80).priority(.required)
        }

        loginButton.snp.makeConstraints { make in
            make.top.equalTo(resetButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(12)
//            make.height.equalTo(42.VAdapted)
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

// MARK: - Delegates

extension LoginOnboardingVC: TextfieldWithIconDelegate, ActionButtonDelegate {
    func setupDelegate() {
        loginTextfield.delegate = self
        passwordTextfield.delegate = self

        loginButton.delegate = self
        resetButton.delegate = self
    }

    func setupTag() {
        loginTextfield.tag = 1
        passwordTextfield.tag = 2

        loginButton.tag = 1
        resetButton.tag = 2
    }

    func textFieldDidBeginEditing(_ textfield: TextfieldWithIcon, didUpdateText text: String) {
        switch textfield.tag {
        /// login:
        case 1:
            if let text = textfield.textField.text {
                viewModel.login = text
            }
        /// password:
        case 2:
            if let text = textfield.textField.text {
                viewModel.password = text
            }
        default:
            break
        }
    }

    func textFieldDidChange(_ textfield: TextfieldWithIcon, didUpdateText text: String) {
        switch textfield.tag {
        /// login:
        case 1:
            if let text = textfield.textField.text {
                viewModel.login = text
            }
        /// password:
        case 2:
            if let text = textfield.textField.text {
                viewModel.password = text
            }
        default:
            break
        }
    }

    func textFieldDidEndEditing(_ textfield: TextfieldWithIcon, didUpdateText text: String) {
        switch textfield.tag {
        /// login:
        case 1:
            if let text = textfield.textField.text {
                viewModel.login = text
            }
        /// password:
        case 2:
            if let text = textfield.textField.text {
                viewModel.password = text
            }
        default:
            break
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() /// Hide keyboard
        return true
    }

    func actionButtonTapped(_ button: ActionButton) {
        switch button.tag {
        case 1:
            Task {
                do {
                    let userModel = try await viewModel.loginUser(email: viewModel.login, password: viewModel.password)
                    if let userModel = userModel {
                        await MainActor.run {
                            self.coordinator?.navigateToApp(user: userModel)
                        }
                    }
                }
            }
        case 2:
            coordinator?.navigateTo(.resetPassword)
        default:
            break
        }
    }
}

extension LoginOnboardingVC: LoginOnboardingDelegate {
    func showLoginErrorAlert() {
        coordinator?.presentAlert(title: "Something went wrong!", message: viewModel.validationError)
    }
}

#if DEBUG
extension LoginOnboardingVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
