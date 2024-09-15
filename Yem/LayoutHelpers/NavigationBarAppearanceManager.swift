//
//  NavigationBarAppearanceManager.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import UIKit

final class NavigationBarAppearanceManager {
    static func setupGlobalAppearance() {
        let barButtonItemAppearance = UIBarButtonItem.appearance()
        barButtonItemAppearance.tintColor = UIColor.ui.theme

        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = UIColor.ui.theme
        navigationBarAppearance.barTintColor = .systemBackground
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.ui.theme]

        UITabBar.appearance().tintColor = .ui.theme
    }
}
