//
//  AppDelegate.swift
//  Yem
//
//  Created by Adam Zapiór on 05/12/2023.
//

import CoreData
import FirebaseCore
import Kingfisher
import LifetimeTracker
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        NavigationBarAppearanceManager.setupGlobalAppearance()

        let cache = ImageCache.default
        cache.diskStorage.config.sizeLimit = 1024 * 1024 * 100

#if DEBUG
        LifetimeTracker.setup(
            onUpdate: LifetimeTrackerDashboardIntegration(
                visibility: .alwaysVisible,
                style: .circular,
                textColorForNoIssues: .systemGreen,
                textColorForLeakDetected: .systemRed
            ).refreshUI
        )
#endif

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
