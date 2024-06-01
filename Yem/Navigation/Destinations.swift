//
//  Destination.swift
//  Yem
//
//  Created by Adam Zapiór on 25/05/2024.
//

import LifetimeTracker
import UIKit

// MARK: - Main destination class

class Destination {
    weak var navigator: Navigator?

    func render() -> UIViewController {
        return UIViewController()
    }

    func attatch(tabBar: UITabBarController) {
        if tabBar.viewControllers == nil {
            tabBar.viewControllers = [render()]
        } else {
            tabBar.viewControllers!.append(render())
        }
    }
}

// MARK: - TabBar destination class

class TabBarDestination: Destination {
    let currentUser: UserModel
    let dataRepository: DataRepository
    let authManager: AuthenticationManager
    
    
    let parentCoordinator: AppCoordinator
    weak var tabBarCoordinator: TabBarCoordinator?

//    override func render() -> UIViewController {
//        navigator?.setNavigationBarHidden()
//        let tabBarCoordinator = TabBarCoordinator(currentUser: currentUser, dataRepository: dataRepository, authManager: authManager)
//        tabBarCoordinator.parentCoordinator = parentCoordinator
//        return tabBarCoordinator
////        return TabBarCoordinator(currentUser: currentUser, dataRepository: dataRepository, authManager: authManager)
//    }
    
    override func render() -> UIViewController {
         tabBarCoordinator?.navigator?.setNavigationBarHidden()
         return tabBarCoordinator ?? UIViewController()
     }

    init(currentUser: UserModel, dataRepository: DataRepository, authManager: AuthenticationManager, parentCoordinator: AppCoordinator, tabBarCoordinator: TabBarCoordinator) {
        self.currentUser = currentUser
        self.dataRepository = dataRepository
        self.authManager = authManager
        self.parentCoordinator = parentCoordinator
        
        self.tabBarCoordinator = tabBarCoordinator

        super.init()
        #if DEBUG
            trackLifetime()
        #endif
    }
}

#if DEBUG
    extension TabBarDestination: LifetimeTrackable {
        class var lifetimeConfiguration: LifetimeConfiguration {
            return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
        }
    }
#endif
