//
//  RegisterOnboardingVC.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import UIKit
import LifetimeTracker


final class RegisterOnboardingVC: UIViewController {

    let coordinator: OnboardingCoordinator
    let viewModel: OnboardingVM
    
    init(coordinator: OnboardingCoordinator, viewModel: OnboardingVM) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

#if DEBUG
        trackLifetime()
#endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always

        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.ui.theme]
        self.title = "Register to Yem"
    }
    
    private func setupUI() {
        
    }
}

#if DEBUG
extension RegisterOnboardingVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
