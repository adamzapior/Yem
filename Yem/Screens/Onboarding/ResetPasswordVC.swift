//
//  ResetPasswordVC.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import Combine
import LifetimeTracker
import UIKit

final class ResetPasswordVC: UIViewController {
    private weak var coordinator: OnboardingCoordinator?
    private let viewModel: OnboardingVM

    private let content = UIView()

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
    private let loginTextfield = TextfieldWithIcon(
        iconImage: "info",
        placeholderText: "Enter your e-mail...",
        textColor: .ui.secondaryText
    )

    private let resetButton = ActionButton(
        title: "Try to reset...",
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

        observeViewModelEventOutput()
        observeTextfields()
        observeActionButton()
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

// MARK: - Observe ViewModel Output & UI actions

extension ResetPasswordVC {
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
    }

    private func observeActionButton() {
        resetButton
            .tapPublisher
            .sink { [unowned self] in
                self.handleActionButtonEvent()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Handle Output & UI Actions

extension ResetPasswordVC {
    private func handleViewModelOutput(event: OnboardingVM.Output) {
        switch event {
        case .loginSuccesed:
            break
        case .updateField(let textField):
           handleUpdateField(for: textField)
        case .showErrorAlert(let alert, message: let message):
            presentAlert(alert, message: message)
        }
    }

    private func handleUpdateField(for field: OnboardingVM.LoginField) {
        DispatchQueue.main.async { [weak self] in
            if case .login(let value) = field {
                self?.loginTextfield.textField.text = value
            }
        }
    }

    private func handleActionButtonEvent() {
        Task {
            try await viewModel.tryResetPassword()
        }
    }
}

// MARK: - Navigation

extension ResetPasswordVC {
    private func presentAlert(_ type: OnboardingVM.AlertType, message: String) {
        DispatchQueue.main.async { [weak self] in
            if type == .resetPasswordFailed {
                self?.coordinator?.presentAlert(.registerError, title: "Something went wrong!", message: message)
            } else if type == .resetPasswordSuccesed {
                self?.coordinator?.presentAlert(.registerError, title: "Password reset successfuly!", message: message)
            }
        }
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension ResetPasswordVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
