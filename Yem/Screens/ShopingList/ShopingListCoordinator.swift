//
//  ShopingListCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import UIKit

final class ShopingListCoordinator {
    
    var parentCoordinator: MainBaseCoordinator?
    
    lazy var rootViewController: UIViewController = UIViewController()
    
    func start() -> UIViewController {
        rootViewController = UINavigationController(rootViewController: ShopingListVC(coordinator: self))
        return rootViewController
    }
    
}
