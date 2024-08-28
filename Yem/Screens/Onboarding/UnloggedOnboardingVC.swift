//
//  UnloggedOnboardingVC.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import Kingfisher
import LifetimeTracker
import SnapKit
import UIKit

final class UnloggedOnboardingVC: UIViewController {
    var viewModel: OnboardingVM
    var coordinator: OnboardingCoordinator?
    
    lazy var image = UIImageView()
        
    private let titleLabel = TextLabel(
        fontStyle: .title1,
        fontWeight: .light,
        textColor: .ui.theme,
        textAlignment: .center
    )
    private let subtitleLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .light,
        textColor: .ui.secondaryText,
        textAlignment: .center
    )

    private let loginButton = ActionButton(
        title: "Login",
        backgroundColor: .ui.theme,
        isShadownOn: true
    )
    private let registerButton = ActionButton(
        title: "Register",
        backgroundColor: .ui.cancelBackground,
        isShadownOn: true
    )
    
    // MARK: - Lifecycle

    init(viewModel: OnboardingVM, coordinator: OnboardingCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        
#if DEBUG
        trackLifetime()
#endif
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("DEBUG: UnloggedOnboardingVC deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupDelegateAndDataSource()
        setupVoiceOverAccessibility()
        
        loginButton.delegate = self
        registerButton.delegate = self
        
        loginButton.tag = 1
        registerButton.tag = 2
        
    }

    // MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(image)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        
        image.image = UIImage(named: "onboarding-image")
        image.sizeToFit()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 24
        
        image.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(loginButton.snp.top).offset(-128)
        }
        
        titleLabel.text = "Welcome to Yem!"
        subtitleLabel.text = "Connect and enjoy. Your journey to unforgettable dining experiences starts here."
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(image.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(-12)
            make.leading.trailing.equalToSuperview().inset(32)
            make.bottom.equalTo(loginButton.snp.top).offset(-12)
        }
        
        loginButton.snp.makeConstraints { make in
            make.bottom.equalTo(registerButton.snp.top).offset(-18)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        registerButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-64)
            make.top.equalTo(loginButton.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }
    
    private func setupDelegateAndDataSource() {
        loginButton.delegate = self
        registerButton.delegate = self
        
        loginButton.tag = 1
        registerButton.tag = 2
    }
    
    private func setupVoiceOverAccessibility() {
        loginButton.isAccessibilityElement = true
        loginButton.accessibilityLabel = "Login button"
        loginButton.accessibilityHint = "Click this button and go to login screen"
        
        registerButton.isAccessibilityElement = true
        registerButton.accessibilityLabel = "Register password button"
        registerButton.accessibilityHint = "Click this button and go to register screen"
    }
}

// MARK: - Navigation

extension UnloggedOnboardingVC: ActionButtonDelegate {
    func actionButtonTapped(_ button: ActionButton) {
        switch button.tag {
        case 1:
            coordinator?.navigateTo(.login)
        case 2:
            coordinator?.navigateTo(.register)
        default:
            break
        }
    }
}

#if DEBUG
extension UnloggedOnboardingVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif

