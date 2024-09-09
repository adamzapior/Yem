//
//  SettingsViewModel.swift
//  Yem
//
//  Created by Adam Zapiór on 03/04/2024.
//

import Foundation
import LifetimeTracker

final class SettingsVM {
    private let authManager: AuthenticationManager

    init(authManager: AuthenticationManager) {
        self.authManager = authManager

#if DEBUG
        trackLifetime()
#endif
    }

    func signOut() async {
        do {
            try await authManager.signOut()
        } catch {
            print(error)
        }
    }
}

// MARK: - LifetimeTracker


#if DEBUG
extension SettingsVM: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewModels")
    }
}
#endif
