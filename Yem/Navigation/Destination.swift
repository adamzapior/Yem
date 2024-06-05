//
//  Destination.swift
//  Yem
//
//  Created by Adam Zapiór on 25/05/2024.
//

import LifetimeTracker
import UIKit

class Destination {
    weak var navigator: Navigator?
    
    func render() -> UIViewController {
         let viewController = UIViewController()
         viewController.destination = self
        print("Destination set in UIViewController: \(self)")
         return viewController
     }

    func attatch(tabBar: UITabBarController) {
        if tabBar.viewControllers == nil {
            tabBar.viewControllers = [render()]
        } else {
            tabBar.viewControllers!.append(render())
        }
    }
}

extension UIViewController {
    private struct AssociatedKeys {
        static var destination: Void?
    }

    var destination: Destination? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.destination) as? Destination
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.destination, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

