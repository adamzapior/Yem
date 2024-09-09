//
//  UnloggedOnboardingVC.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import Combine
import CombineCocoa
import LifetimeTracker
import SnapKit
import UIKit

final class UnloggedOnboardingVC: UIViewController {
    private weak var coordinator: OnboardingCoordinator?
    private let viewModel: OnboardingVM
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private lazy var image = UIImageView()
        
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
    
    private var cancellables = Set<AnyCancellable>()

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupVoiceOverAccessibility()
    
        observeButtons()
    }

    // MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(image)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(loginButton)
        contentView.addSubview(registerButton)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.showsVerticalScrollIndicator = false
        
        contentView.snp.makeConstraints { make in
            make.top.trailing.leading.bottom.equalToSuperview()
            make.width.equalTo(view)
        }
        
        image.image = UIImage(named: "onboarding-image")
        image.contentMode = .scaleAspectFit
        
        image.clipsToBounds = true
        
        image.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-64)
            make.leading.trailing.equalToSuperview()
            make.height.lessThanOrEqualTo(view.snp.height).multipliedBy(0.5)
        }

        titleLabel.text = "Welcome to Yem!"
        subtitleLabel.text = "Connect and enjoy. Your journey to unforgettable dining experiences starts here."
        	
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(image.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(32)
            make.bottom.equalTo(registerButton.snp.top).offset(-24)
        }
        
        registerButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(32)
            make.bottom.equalTo(loginButton.snp.top).offset(-16)
        }
        
        loginButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(32)
            make.bottom.equalToSuperview().offset(-32)
        }
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

// MARK: - Observe ViewModel Output & UI actions

extension UnloggedOnboardingVC {
    private func observeButtons() {
        loginButton
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                self.handleActionButtonEvent(type: .login)
            }
            .store(in: &cancellables)
        
        registerButton
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                self.handleActionButtonEvent(type: .register)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Handle Output & UI Actions

extension UnloggedOnboardingVC {
    private func handleActionButtonEvent(type: ButtonType) {
        switch type {
        case .login:
            navigateToLoginScreen()
        case .register:
            navigateToRegisterScreen()
        }
    }
}

// MARK: - Navigation

extension UnloggedOnboardingVC {
    private func navigateToLoginScreen() {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.navigateTo(.login)
        }
    }
    
    private func navigateToRegisterScreen() {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.navigateTo(.register)
        }
    }
}

// MARK: - Helper enum

extension UnloggedOnboardingVC {
    private enum ButtonType {
        case login
        case register
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension UnloggedOnboardingVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
