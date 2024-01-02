//
//  RecipesListCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import UIKit

final class RecipesListCoordinator {
    var parentCoordinator: MainBaseCoordinator?
    
    lazy var rootViewController: UIViewController = .init()
    let viewModel = RecipesListVM()
    
    func start() -> UIViewController {
        rootViewController = UINavigationController(rootViewController: RecipesListVC(coordinator: self, viewModel: viewModel))
        return rootViewController
    }
    
    
    func goToAddRecipeScreen() {
        let viewModel = AddRecipeViewModel()
        
        // Utwórz koordynatora, przekazując istniejący UINavigationController.
        let coordinator = AddRecipeCoordinator(navigationController: rootViewController as? UINavigationController, viewModel: viewModel)
        coordinator.parentCoordinator = self

        // Wywołanie start na koordynatorze, aby rozpocząć przepływ.
        let addRecipeVC = coordinator.start()
        addRecipeVC.hidesBottomBarWhenPushed = true

        // Użyj istniejącego UINavigationController do push.
        (rootViewController as? UINavigationController)?.pushViewController(addRecipeVC, animated: true)
    }
}
