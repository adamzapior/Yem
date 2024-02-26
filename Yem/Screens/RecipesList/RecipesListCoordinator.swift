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
    let repository: DataRepository
    let viewModel: RecipesListVM
    
    init(parentCoordinator: MainBaseCoordinator? = nil, repository: DataRepository, viewModel: RecipesListVM) {
        self.parentCoordinator = parentCoordinator
        self.repository = repository
        self.viewModel = viewModel
    }
    
    func start() -> UIViewController {
        rootViewController = UINavigationController(rootViewController: RecipesListVC(coordinator: self, viewModel: viewModel))

        return rootViewController
    }
    
    func goToAddRecipeScreen() {
        let viewModel = AddRecipeViewModel(repository: repository)
        
        let coordinator = AddRecipeCoordinator(navigationController: rootViewController as? UINavigationController, viewModel: viewModel)
        coordinator.parentCoordinator = self

        let addRecipeVC = coordinator.start()
        addRecipeVC.hidesBottomBarWhenPushed = true

        (rootViewController as? UINavigationController)?.pushViewController(addRecipeVC, animated: true)
    }
    
    func navigateToRecipeDetail(with recipe: RecipeModel) {
        let viewModel = RecipeDetailsVM(repository: repository)
        
        let coordinator = RecipeDetailsCoordinator(navigationController: rootViewController as? UINavigationController, viewModel: viewModel, recipe: recipe, repository: repository)        
        coordinator.parentCoordinator = self

        let detailsVC = coordinator.start()
        detailsVC.hidesBottomBarWhenPushed = true
        
        (rootViewController as? UINavigationController)?.pushViewController(detailsVC, animated: true)
    }
}
