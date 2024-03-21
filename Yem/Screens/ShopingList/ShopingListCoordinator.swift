//
//  ShopingListCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import UIKit

final class ShopingListCoordinator {
    
    var parentCoordinator: MainBaseCoordinator?
    let repository: DataRepository
    let viewModel: ShopingListVM
    
    lazy var rootViewController: UIViewController = UIViewController()
    
    init(parentCoordinator: MainBaseCoordinator? = nil, repository: DataRepository, viewModel: ShopingListVM) {
        self.parentCoordinator = parentCoordinator
        self.repository = repository
        self.viewModel = viewModel
    }
    
    func start() -> UIViewController {
        rootViewController = UINavigationController(rootViewController: ShopingListVC(coordinator: self, viewModel: viewModel))
        return rootViewController
    }
    
    func presentClearShopingListAlert() {
        let title: String = "Remove ingredients"
        let message: String = "Do you want to remove all ingredients from shoping list?"
        
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
