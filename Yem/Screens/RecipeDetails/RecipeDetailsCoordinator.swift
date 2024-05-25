//
//  RecipeDetailsCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 20/02/2024.
//

import LifetimeTracker
import UIKit

final class RecipeDetailsCoordinator: ParentCoordinator, ChildCoordinator {
    var childCoordinators: [Coordinator] = []
    var viewControllerRef: UIViewController?
    var navigationController: UINavigationController

    var recipe: RecipeModel
    var repository: DataRepository
    var viewModel: RecipeDetailsVM

    init(navigationController: UINavigationController, viewModel: RecipeDetailsVM, recipe: RecipeModel, repository: DataRepository) {
        self.navigationController = navigationController
        self.viewModel = viewModel
        self.recipe = recipe
        self.repository = repository

#if DEBUG
        trackLifetime()
#endif
    }

    func start(animated: Bool) {
        let recipesDetailsController = RecipeDetailsVC(recipe: recipe, viewModel: viewModel, coordinator: self)

        viewControllerRef = recipesDetailsController
        navigationController.customPushViewController(viewController: recipesDetailsController, direction: .fromRight, transitionType: .moveIn)
    }

    func coordinatorDidFinish() {
        if let viewController = viewControllerRef as? DisposableViewController {
            viewController.cleanUp()
        }
        viewControllerRef = nil
        print("DEBUG: coordinatorDidFinish() called")
    }

    func childDidFinish(_ child: Coordinator) {
        if let index = childCoordinators.firstIndex(where: { $0 === child }) {
            childCoordinators.remove(at: index)
        }
    }

    func presentAddIngredientsToShopingListAlert() {
        let title = "Add ingredients to list"
        let message = "Do you want o add all ingredients to shoping list?"

        let alertVC = DualOptionAlertVC(title: title, message: message) {
            self.viewModel.addIngredientsToShopingList()
            self.dismissAlert()
        } cancelAction: {
            self.dismissAlert()
        }
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        navigationController.present(alertVC, animated: true, completion: nil)
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
        navigationController.present(alertVC, animated: true, completion: nil)
    }

    func presentDeleteRecipeAlert() {
        let title = "Remove recipe"
        let message = "Do you want to remove this recipe from your recipes list?"

        let alertVC = DualOptionAlertVC(title: title, message: message) {
            self.viewModel.deleteRecipe()
            self.dismissVC()
        } cancelAction: {
            self.dismissAlert()
        }
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        navigationController.present(alertVC, animated: true, completion: nil)
    }

    func navigateToRecipeEditor() {
        let viewModel = AddRecipeViewModel(repository: repository, existingRecipe: recipe)
        let coordinator = AddRecipeCoordinator(navigationController: navigationController, viewModel: viewModel, parentCoordinator: self)

        coordinator.start(animated: true)
    }

    func dismissAlert() {
        navigationController.dismiss(animated: true)
    }

    func dismissVC() {
        navigationController.customPopToRootViewController()
    }
}

#if DEBUG
extension RecipeDetailsCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
