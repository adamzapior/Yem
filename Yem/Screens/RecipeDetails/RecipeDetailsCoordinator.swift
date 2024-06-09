//
//  RecipeDetailsCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 20/02/2024.
//

import LifetimeTracker
import UIKit

final class RecipeDetailsCoordinator: Destination {
    var recipe: RecipeModel
    var repository: DataRepository
    var viewModel: RecipeDetailsVM

    weak var parentCoordinator: Destination?

    init(viewModel: RecipeDetailsVM, recipe: RecipeModel, repository: DataRepository) {
        self.viewModel = viewModel
        self.recipe = recipe
        self.repository = repository

        super.init()
#if DEBUG
        trackLifetime()
#endif
    }

    override func render() -> UIViewController {
        let controller = RecipeDetailsVC(recipe: recipe, viewModel: viewModel, coordinator: self)
        controller.destination = self
        controller.hidesBottomBarWhenPushed = true
        return controller
    }

    func presentAddIngredientsToShopingListAlert() {
        let title = "Add ingredients to list"
        let message = "Do you want o add all ingredients to shoping list?"

        let alertVC = DualOptionAlertVC(title: title, message: message) {
            self.viewModel.addIngredientsToShopingList()
            self.navigator?.dismissAlert()
        } cancelAction: {
            self.navigator?.dismissAlert()
        }
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        navigator?.presentAlert(alertVC)
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
            self.navigator?.dismissAlert()
        } cancelAction: {
            self.navigator?.dismissAlert()
        }
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        navigator?.presentAlert(alertVC)
    }

    func presentDeleteRecipeAlert() {
        let title = "Remove recipe"
        let message = "Do you want to remove this recipe from your recipes list?"

        let alertVC = DualOptionAlertVC(title: title, message: message) {
            self.viewModel.deleteRecipe()
            self.navigator?.pop()
        } cancelAction: {
            self.navigator?.dismissAlert()
        }
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        navigator?.presentAlert(alertVC)
    }

    func navigateToRecipeEditor() {
        let viewModel = AddRecipeViewModel(repository: repository)
        let coordinator = AddRecipeCoordinator(viewModel: viewModel)
        coordinator.parentCoordinator = self
        navigator?.presentDestination(coordinator)
    }
}

#if DEBUG
extension RecipeDetailsCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
