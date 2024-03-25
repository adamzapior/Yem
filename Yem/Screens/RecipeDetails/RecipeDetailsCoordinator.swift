//
//  RecipeDetailsCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 20/02/2024.
//

import UIKit

final class RecipeDetailsCoordinator {
    var recipe: RecipeModel
    var parentCoordinator: RecipesListCoordinator?
    var repository: DataRepository
    var viewModel: RecipeDetailsVM
    weak var navigationController: UINavigationController?
    

    init(navigationController: UINavigationController?, viewModel: RecipeDetailsVM, recipe: RecipeModel, repository: DataRepository) {
        self.navigationController = navigationController
        self.viewModel = viewModel
        self.recipe = recipe
        self.repository = repository
    }

    func start() -> UIViewController {
        let detailsVC = RecipeDetailsVC(recipe: recipe, viewModel: viewModel, coordinator: self)
        return detailsVC
    }
    
    func presentAddIngredientsToShopingListAlert() {
        let title: String = "Add ingredients to list"
        let message: String = "Do you want o add all ingredients to shoping list?"
        
        let alertVC = DualOptionAlertVC(title: title, message: message) {
            self.viewModel.addIngredientsToShopingList()
            self.dismissAlert()
        } cancelAction: {
            self.dismissAlert()
        }
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            navigationController?.present(alertVC, animated: true, completion: nil)
    }

    func presentAddToFavouritesAlert() {
        let isFavorite = viewModel.isFavourite

        let title: String
        let message: String

        if isFavorite {
            title = "Remove from favorites"
            message = "Do you want to remove this recipe from your favorites?"
        } else {
            title = "Add to favorites"
            message = "Do you want to add this recipe to your favorites?"
        }

        let alertVC = DualOptionAlertVC(title: title, message: message) {
            self.viewModel.toggleFavouriteStatus()
            self.dismissAlert()
        } cancelAction: {
            self.dismissAlert()
        }
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            navigationController?.present(alertVC, animated: true, completion: nil)
    }
    
    func presentDeleteRecipeAlert() {
        let title: String = "Remove recipe"
        let message: String = "Do you want to remove this recipe from your recipes list?"
        
        let alertVC = DualOptionAlertVC(title: title, message: message) {
            self.viewModel.deleteRecipe()
            self.dismissVC()
        } cancelAction: {
            self.dismissAlert()
        }
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            navigationController?.present(alertVC, animated: true, completion: nil)
    }

    func navigateToRecipeEditor() {
        let viewModel = AddRecipeViewModel(repository: repository, existingRecipe: recipe)

        let coordinator = AddRecipeCoordinator(navigationController: navigationController, viewModel: viewModel)
        coordinator.parentCoordinator = self

        let addRecipeVC = coordinator.start()
        addRecipeVC.hidesBottomBarWhenPushed = true

        (navigationController)?.pushViewController(addRecipeVC, animated: true)
    }
    
    func dismissAlert() {
        navigationController?.dismiss(animated: true)
    }

    func dismissVC() {
        navigationController?.popToRootViewController(animated: true)
    }
}
