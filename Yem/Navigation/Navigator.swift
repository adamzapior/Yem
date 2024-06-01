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
    
    var navigationController: UINavigationController {
         return delegate
     }
    
    // Inicjalizator z opcjonalnym rootViewController
    init(rootViewController: UIViewController? = nil) {
        if let rootVC = rootViewController {
            delegate = UINavigationController(rootViewController: rootVC)
        } else {
            delegate = UINavigationController()
        }
    }
    
    func clearAllViewControllers() {
         delegate.viewControllers = []
     }
    
//    init() {
//
//    }
    
    
    func goTo(screen: Destination) {
        print("Navigating to screen: \(screen)")
        screen.navigator = self
        delegate.pushViewController(screen.render(), animated: true)
    }
    
    func goTo22(screen: UIViewController) {
        print("Navigating to UIViewController: \(screen)")
        delegate.pushViewController(screen, animated: true)
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
