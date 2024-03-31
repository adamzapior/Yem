//
//  LoginOnboardingVC.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import LifetimeTracker
import UIKit

final class LoginOnboardingVC: UIViewController {
    let coordinator: OnboardingCoordinator
    let viewModel: OnboardingVM
    
    let loginTextfield = TextfieldWithIcon(iconImage: "", placeholderText: "Enter your login...", textColor: .ui.secondaryText)
    let passwordTextfield = TextfieldWithIcon(iconImage: "", placeholderText: "Enter your login...", textColor: .ui.secondaryText)


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

        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always

        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.ui.theme]
        self.title = "Login to Yem"
        
        setupUI()
    }
    
    private func setupUI() {
        
    }
}

// MARK: - Delegates

extension LoginOnboardingVC: LoginOnboardingDelegate {
    func showAlert() {
        //
    }
}

extension LoginOnboardingVC: TextfieldWithIconDelegate {
    func setupDelegate() {
        //
    }
    
    func setupTag() {
        //

    }
    
    func textFieldDidBeginEditing(_ textfield: TextfieldWithIcon, didUpdateText text: String) {
        //

    }
    
    func textFieldDidChange(_ textfield: TextfieldWithIcon, didUpdateText text: String) {
        //

    }
    
    func textFieldDidEndEditing(_ textfield: TextfieldWithIcon, didUpdateText text: String) {
        //

    }
    
    
}



// MARK: - Navigation

#if DEBUG
extension LoginOnboardingVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
