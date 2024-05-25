//
//  Navigator.swift
//  Yem
//
//  Created by Adam Zapiór on 25/04/2024.
//

import UIKit

final class Navigator {
    
    private let delegate: UINavigationController
    
    init(start: Destination) {
        delegate = UINavigationController()
        start.navigator = self
        delegate.pushViewController(start.render(), animated: true)
    }
    
//    init() {
//        
//    }
    
    func goTo(screen: Destination) {
        screen.navigator = self
        delegate.pushViewController(screen.render(), animated: true)
    }
    
    func pop() {
        delegate.popViewController(animated: true)
    }
    
    func popUpTo(predicate: (Destination) -> Bool) {
//        guard let controller = delegate.viewControllers.last(where: { predicate($0 as! Destination) }) else {
//            return
//        }
//        delegate.popToViewController(controller, animated: true)
////        backstack.removeLast(backstack.count - index + 1)
    }
    
    func attatch(appWindow: UIWindow) {
        appWindow.rootViewController = delegate
    }
    
    func changeRoot(screen: Destination) {
        delegate.setViewControllers([screen.render()], animated: true)
    }
    
    func setNavigationBarHidden(bool: Bool = true) {
        delegate.setNavigationBarHidden(bool, animated: false)
    }
    
    func present(alert: UIViewController) {
        delegate.present(alert, animated: true, completion: nil)
    }
    
    func dismissAlert() {
        delegate.dismiss(animated: true)
    }
}

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
