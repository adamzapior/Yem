//
//  RecipesListCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import LifetimeTracker
import UIKit

final class RecipesListCoordinator: Destination {
    let authManager: AuthenticationManager
    let repository: DataRepository
    var viewModel: RecipesListVM

    init(repository: DataRepository, viewModel: RecipesListVM, authManager: AuthenticationManager) {
        self.repository = repository
        self.viewModel = viewModel
        self.authManager = authManager
        super.init()
#if DEBUG
        trackLifetime()
#endif
    }

    override func render() -> UIViewController {
        let controller = RecipesListVC(coordinator: self, viewModel: viewModel)
        controller.destination = self
        return controller
    }

    // MARK: Navigation

    func navigateToAddRecipeScreen() {
        let viewModel = AddRecipeViewModel(repository: repository)
        let coordinator = AddRecipeCoordinator(viewModel: viewModel)
        coordinator.parentCoordinator = self
        navigator?.presentDestination(coordinator)
    }

    func navigateToRecipeDetail(with recipe: RecipeModel) {
        let viewModel = RecipeDetailsVM(recipe: recipe, repository: repository)
        let coordinator = RecipeDetailsCoordinator(viewModel: viewModel, recipe: recipe, repository: repository)
        coordinator.parentCoordinator = self
        navigator?.presentDestination(coordinator)
    }

    func navigateToSettings() {
        let viewModel = SettingsViewModel(authManager: authManager)
        let coordinator = SettingsCoordinator(viewModel: viewModel)
        coordinator.parentCoordinator = self
        navigator?.presentDestination(coordinator)
    }
}

#if DEBUG
extension RecipesListCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
