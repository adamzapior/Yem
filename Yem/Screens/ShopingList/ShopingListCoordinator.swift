//
//  ShopingListCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import LifetimeTracker
import UIKit

final class ShopingListCoordinator: Destination {
    private weak var parentCoordinator: TabBarCoordinator?
    
    let repository: DataRepository
    let viewModel: ShopingListVM
    
    init(parentCoordinator: TabBarCoordinator? = nil, repository: DataRepository, viewModel: ShopingListVM) {
        self.parentCoordinator = parentCoordinator
        self.repository = repository
        self.viewModel = viewModel
        
        super.init()
#if DEBUG
        trackLifetime()
#endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func render() -> UIViewController {
        let shopingListController = ShopingListVC(coordinator: self, viewModel: viewModel)
        shopingListController.viewModel = viewModel
        
        shopingListController.tabBarItem = UITabBarItem(title: "Shoping list",
                                                        image: UIImage(systemName: "basket"),
                                                        selectedImage: nil)
        return shopingListController
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
        navigator?.present(alert: alertVC)
    }
    
    private func dismissAlert() {
        navigator?.dismissAlert()
    }
}

#if DEBUG
extension ShopingListCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
