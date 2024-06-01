//
//  TabCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 25/05/2024.
//

import UIKit

class TabCoordinator: Destination {
    var rootViewController: UINavigationController
    var childDestination: Destination

    init(childDestination: Destination) {
        self.childDestination = childDestination
        self.rootViewController = UINavigationController(rootViewController: childDestination.render())
        super.init()
    }

    override func render() -> UIViewController {
        return rootViewController
    }

    func attach(tabBar: UITabBarController) {
        tabBar.viewControllers?.append(rootViewController)
    }
}
