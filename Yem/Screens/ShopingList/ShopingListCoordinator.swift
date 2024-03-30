//
//  ShopingListCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import LifetimeTracker
import UIKit

final class ShopingListCoordinator: ParentCoordinator, ChildCoordinator {
    var parentCoordinator: TabBarCoordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var viewControllerRef: UIViewController?
    
    lazy var rootViewController: UIViewController = .init()
    let repository: DataRepository
    let viewModel: ShopingListVM
    
    init(parentCoordinator: TabBarCoordinator? = nil, repository: DataRepository, viewModel: ShopingListVM, navigationController: UINavigationController) {
        self.parentCoordinator = parentCoordinator
        self.repository = repository
        self.viewModel = viewModel
        self.navigationController = navigationController
        
#if DEBUG
        trackLifetime()
#endif
    }

    func start(animated: Bool) {
        let shopingListController = ShopingListVC(coordinator: self, viewModel: viewModel)
        shopingListController.viewModel = viewModel
        
        viewControllerRef = shopingListController
        shopingListController.tabBarItem = UITabBarItem(title: "Shoping list",
                                                        image: UIImage(systemName: "basket"),
                                                        selectedImage: nil)
        navigationController.customPushViewController(viewController: shopingListController)
    }
    
    func coordinatorDidFinish() {
        if let viewController = viewControllerRef as? DisposableViewController {
            viewController.cleanUp()
        }
//        parentCoordinator?.childDidFinish(self)
    }
    
    func presentClearShopingListAlert() {
        let title = "Remove ingredients"
        let message = "Do you want to remove all ingredients from shoping list?"
        
        let alertVC = DualOptionAlertVC(title: title, message: message) {
            self.viewModel.clearShopingList()
            self.dismissAlert()
        } cancelAction: {
            self.dismissAlert()
        }
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        rootViewController.present(alertVC, animated: true, completion: nil)
    }
    
    private func dismissAlert() {
        rootViewController.dismiss(animated: true)
    }
}

#if DEBUG
extension ShopingListCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
