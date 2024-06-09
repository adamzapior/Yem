//
//  Destination.swift
//  Yem
//
//  Created by Adam Zapiór on 08/06/2024.
//

import UIKit

class Destination {
    weak var navigator: Navigator?

    func render() -> UIViewController {
        let viewController = UIViewController()
        viewController.destination = self
        return viewController
    }
}


extension UIViewController {
    private enum AssociatedKeys {
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
