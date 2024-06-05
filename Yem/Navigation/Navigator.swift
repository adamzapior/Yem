//
//  Navigator.swift
//  Yem
//  Created by Adam Zapiór on 25/04/2024.
//

import UIKit

final class Navigator {
    // MARK: - Properties
    
    private let delegate: UINavigationController
    
    var navigationController: UINavigationController {
        return delegate
    }
    
    // MARK: - Initialization
    
    init(start: Destination) {
        delegate = UINavigationController()
        start.navigator = self
        delegate.pushViewController(start.render(), animated: true)
    }
    
    // MARK: - Configuration
    
    func attach(appWindow: UIWindow) {
        appWindow.rootViewController = delegate
    }
    
    func setNavigationBarHidden(_ hidden: Bool = true) {
        delegate.setNavigationBarHidden(hidden, animated: false)
    }
    
    func changeRoot(screen: Destination) {
        delegate.setViewControllers([screen.render()], animated: true)
    }
    
    // MARK: - Navigation Commands
    
    func presentDestination(_ destination: Destination) {
        print("Navigating to screen: \(destination)")
        destination.navigator = self
        delegate.pushViewController(destination.render(), animated: true)
    }
    
    func presentScreen(_ screen: UIViewController) {
        print("Navigating to UIViewController: \(screen)")
        delegate.pushViewController(screen, animated: true)
    }
    
    func pop() {
        delegate.popViewController(animated: true)
    }
    
    func popUpToRoot() {
        delegate.popToRootViewController(animated: true)
    }
    
    func popUpTo(predicate: @escaping (Destination) -> Bool) {
        DispatchQueue.main.async {
            guard let controller = self.delegate.viewControllers.last(where: { viewController in
                let destinationIsCorrect = (viewController.destination).map(predicate) ?? false
                print("Checking destination: \(String(describing: viewController.destination)), passes: \(destinationIsCorrect)")
                return destinationIsCorrect
            }) else {
                print("No matching controller found.")
                return
            }
            print("Popping to controller: \(controller)")
            self.delegate.popToViewController(controller, animated: true)
        }
    }
    
    // MARK: - Alert Management
    
    func present(alert: UIViewController) {
        delegate.present(alert, animated: true, completion: nil)
    }
    
    func dismissAlert() {
        delegate.dismiss(animated: true)
    }
    
    // MARK: - Logout Management
    
    func clearAllViewControllers() {
        DispatchQueue.main.async {
            self.delegate.viewControllers = []
        }
    }
}
