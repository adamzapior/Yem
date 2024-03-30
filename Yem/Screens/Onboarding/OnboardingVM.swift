//
//  OnboardingVM.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import Foundation
import LifetimeTracker


final class OnboardingVM {
    
    init() {
#if DEBUG
        trackLifetime()
#endif
    }
    
}

#if DEBUG
extension OnboardingVM: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewModels")
    }
}
#endif
