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
        rootViewController = UINavigationController(rootViewController: ShopingListVC(coordinator: self, repository: repository, viewModel: viewModel))
        return rootViewController
    }
    
}
