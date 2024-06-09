//
//  RegisterOnboardingVC.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import FirebaseAuth
import LifetimeTracker
import UIKit

final class RegisterOnboardingVC: UIViewController {
    let coordinator: OnboardingCoordinator
    let viewModel: OnboardingVM

    var content = UIView()

    let textLabel = TextLabel(fontStyle: .title2, fontWeight: .light, textColor: .ui.secondaryText)
    let loginLabel = TextLabel(fontStyle: .footnote, fontWeight: .light, textColor: .ui.secondaryText)
    let passwordLabel = TextLabel(fontStyle: .footnote, fontWeight: .light, textColor: .ui.secondaryText)

    let loginTextfield = TextfieldWithIcon(iconImage: "info", placeholderText: "Enter your login...", textColor: .ui.secondaryText)
    let passwordTextfield = TextfieldWithIcon(iconImage: "staroflife", placeholderText: "Enter your new password...", textColor: .ui.secondaryText)

    let loginButton = ActionButton(title: "Register...", backgroundColor: .ui.addBackground, isShadownOn: true)

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

        setupUI()
        setupDelegate()
        setupTag()
        setupTextfieldBehaviour() 

        loginButton.delegate = self
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

        textLabel.text = "Register"
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

        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextfield.snp.bottom).offset(36)
            make.leading.trailing.equalToSuperview().inset(12)
        }
    }
    
    private func setupTextfieldBehaviour() {
        loginTextfield.textField.autocapitalizationType = .none
        passwordTextfield.textField.autocapitalizationType = .none
        passwordTextfield.textField.isSecureTextEntry = true
    }
}

extension RegisterOnboardingVC: TextfieldWithIconDelegate, ActionButtonDelegate {
    func setupDelegate() {
        loginTextfield.delegate = self
        passwordTextfield.delegate = self
    }

    func setupTag() {
        loginTextfield.tag = 1
        passwordTextfield.tag = 2
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
        Task {
            do {
                let userModel = try await viewModel.createUser(email: viewModel.login, password: viewModel.password)
            } catch {
                print("Błąd podczas rejestracji: \(error)")
            }
        }
    }
}

#if DEBUG
extension RegisterOnboardingVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
