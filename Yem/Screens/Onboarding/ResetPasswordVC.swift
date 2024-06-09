//
//  ResetPasswordVC.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import LifetimeTracker
import UIKit

final class ResetPasswordVC: UIViewController {
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

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {}

}

// MARK: - Navigation


#if DEBUG
extension ResetPasswordVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
