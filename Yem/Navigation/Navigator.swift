
//  Navigator.swift
//  Yem
//  Created by Adam Zapiór on 25/04/2024.

import UIKit

final class Navigator {
    let navigationController: UINavigationController

    init(start: Destination) {
        navigationController = UINavigationController(rootViewController: start.render())
        start.navigator = self
    }

    // MARK: - Configuration

    func attach(appWindow: UIWindow) {
        appWindow.rootViewController = navigationController
    }

    func setNavigationBarHidden(_ hidden: Bool = true) {
        navigationController.setNavigationBarHidden(hidden, animated: false)
    }

    // MARK: - Navigation Commands

    func presentDestination(_ destination: Destination) {
        print("DEBUG: Navigating to screen: \(destination)")
        destination.navigator = self
        navigationController.pushViewController(destination.render(), animated: true)
    }

    func presentScreen(_ screen: UIViewController, isAnimated: Bool = true) {
        print("DEBUG: Navigating to UIViewController: \(screen)")
        navigationController.pushViewController(screen, animated: isAnimated)
    }

    func pop() {
        navigationController.popViewController(animated: true)
    }

    func popUpTo(where predicate: @escaping (Destination) -> Bool) {
        DispatchQueue.main.async { [weak self] in
            if let viewController = self?.navigationController.viewControllers.last(where: { $0.destination.map(predicate) ?? false }) {
                print("DEBUG: Checking destination: \(String(describing: viewController.destination))")
                self?.navigationController.popToViewController(viewController, animated: true)
            }
        }
    }

    func popUpToRoot() {
        navigationController.popToRootViewController(animated: true)
    }

    func changeRoot(screen: Destination) {
        screen.navigator = self
        navigationController.setViewControllers([screen.render()], animated: true)
    }

    // MARK: - Sheet Management

    func presentSheet(_ screen: UIViewController) {
        screen.modalPresentationStyle = .formSheet
        navigationController.present(screen, animated: true, completion: nil)
    }

    func dismissSheet() {
        navigationController.dismiss(animated: true, completion: nil)
    }

    // MARK: - Alert Management

    func presentAlert(_ vc: UIViewController) {
        navigationController.present(vc, animated: true, completion: nil)
    }

    func dismissAlert() {
        navigationController.dismiss(animated: true)
    }

    // MARK: - Logout Management

    func clearAllViewControllers() {
        DispatchQueue.main.async {
            self.navigationController.viewControllers = []
        }
    }
}

