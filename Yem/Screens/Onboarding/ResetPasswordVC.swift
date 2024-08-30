//
//  ResetPasswordVC.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import FirebaseAuth
import LifetimeTracker
import UIKit

final class ResetPasswordVC: UIViewController {
    weak var coordinator: OnboardingCoordinator?
    let viewModel: OnboardingVM

    var content = UIView()

    let titleLabel = TextLabel(
        fontStyle: .title2,
        fontWeight: .light,
        textColor: .ui.secondaryText,
        textAlignment: .center
    )
    let loginLabel = TextLabel(
        fontStyle: .footnote,
        fontWeight: .light,
        textColor: .ui.secondaryText
    )
    let loginTextfield = TextfieldWithIcon(
        iconImage: "info",
        placeholderText: "Enter your e-mail...",
        textColor: .ui.secondaryText
    )

    let resetButton = ActionButton(
        title: "Try to reset...",
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
        setupTextfieldBehaviour()

        viewModel.delegateResetOnb = self
        resetButton.delegate = self
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.addSubview(content)

        content.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(84)
            make.leading.trailing.bottom.equalToSuperview().inset(18)
        }

        content.addSubview(titleLabel)
        content.addSubview(loginLabel)
        content.addSubview(loginTextfield)
        content.addSubview(resetButton)

        titleLabel.text = "Reset your password"
        loginLabel.text = "E-mail"

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

        resetButton.isAccessibilityElement = true

        resetButton.snp.makeConstraints { make in
            make.top.equalTo(loginTextfield.snp.bottom).offset(36)
            make.leading.trailing.equalToSuperview().inset(12)
        }
    }

    private func setupTextfieldBehaviour() {
        loginTextfield.textField.autocapitalizationType = .none
    }

    private func setupVoiceOverAccesibility() {
        loginTextfield.isAccessibilityElement = true
        loginTextfield.accessibilityLabel = "Login textfield"
        loginTextfield.accessibilityHint = "Enter your e-mail"

        resetButton.isAccessibilityElement = true
        resetButton.accessibilityLabel = "Reset password button"
        resetButton.accessibilityHint = "Click this button and reset password"
    }
}

extension ResetPasswordVC: TextfieldWithIconDelegate, ActionButtonDelegate {
    func setupDelegate() {
        loginTextfield.delegate = self
    }

    func setupTag() {
        loginTextfield.tag = 1
    }

    func textFieldDidBeginEditing(_ textfield: TextfieldWithIcon, didUpdateText text: String) {
        switch textfield.tag {
        /// login:
        case 1:
            if let text = textfield.textField.text {
                viewModel.login = text
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
        default:
            break
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() /// Hide keyboard
        return true
    }

    func actionButtonTapped(_ button: ActionButton) {
        Task {
            do {
                try await viewModel.resetPassword(email: viewModel.login)

                await MainActor.run {
                    coordinator?.presentPasswordResetAlert()
                }
            }
        }
    }
}

extension ResetPasswordVC: ResetPasswordVCDelegate {
    func showResetErrorAlert() {
        coordinator?.presentAlert(title: "Something went wrong!", message: viewModel.validationError)
    }
}

#if DEBUG
extension ResetPasswordVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
