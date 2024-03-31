//
//  OnboardingVM.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import Foundation
import LifetimeTracker

protocol LoginOnboardingDelegate: AnyObject {
    func showAlert()
}

final class OnboardingVM {
    
    weak var delegeteLoginOnb: LoginOnboardingDelegate?
    
    init() {
#if DEBUG
        trackLifetime()
#endif
    }
    
}

extension OnboardingVM: LoginOnboardingDelegate {
    func showAlert() {
        DispatchQueue.main.async { [weak self] in
            self?.delegeteLoginOnb?.showAlert()
        }
    }
    
    
}

#if DEBUG
extension OnboardingVM: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewModels")
    }
}
#endif
