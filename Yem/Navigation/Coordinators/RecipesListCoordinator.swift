//
//  RecipesListCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import LifetimeTracker
import UIKit

final class RecipesListCoordinator: Destination {
    private weak var parentCoordinator: TabBarCoordinator?
        
    let authManager: AuthenticationManager
    let repository: DataRepository
    var viewModel: RecipesListVM
    
    var tabNavigator: Navigator?

    init(parentCoordinator: TabBarCoordinator?, repository: DataRepository, viewModel: RecipesListVM, authManager: AuthenticationManager) {
        self.parentCoordinator = parentCoordinator
        self.repository = repository
        self.viewModel = viewModel
        self.authManager = authManager
        super.init()
#if DEBUG
        trackLifetime()
#endif
    }
    
    override func render() -> UIViewController {
        let recipesListController = RecipesListVC(coordinator: self, viewModel: viewModel)
        recipesListController.viewModel = viewModel
                
        recipesListController.tabBarItem = UITabBarItem(title: "Recipes",
                                                        image: UIImage(systemName: "book"),
                                                        selectedImage: nil)
        return recipesListController
    }

    // MARK: Navigation
    
    func navigateToAddRecipeScreen() {
        print("Navigating to Add Recipe Screen")
        let viewModel = AddRecipeViewModel(repository: repository)
        let addRecipeCoordinator = AddRecipeCoordinator(viewModel: viewModel)
        print("AddRecipeCoordinator created with viewModel: \(viewModel)")
        tabNavigator?.goTo(screen: addRecipeCoordinator)
        print("navigator is: \(String(describing: navigator))")
    }
    
    func navigateToRecipeDetail(with recipe: RecipeModel) {
//        let viewModel = RecipeDetailsVM(recipe: recipe, repository: repository)
//        let coordinator = RecipeDetailsCoordinator(navigationController: navigationController, parentCoordinator: self, viewModel: viewModel, recipe: recipe, repository: repository)
//        coordinator.start(animated: true)
    }
    
    func navigateToSettings() {
        let viewModel = SettingsViewModel(authManager: authManager)
        let settingsCoordinator = SettingsCoordinator(viewModel: viewModel)
        settingsCoordinator.parentCoordinator = self
        navigator?.goTo(screen: settingsCoordinator)
//        tabNavigator?.goTo(screen: settingsCoordinator)
//        let coordinator = SettingsCoordinator(parentCoordinator: self, viewControllerRef: nil, navigationController: navigationController, viewModel: viewModel)
//
//        coordinator.start(animated: true)
//        (navigationController).pushViewController(addRecipeVC, animated: true)
    }
    
    func resetApplication() {
        print("resetApplication from RecipesListCoordinator")
        print(parentCoordinator.debugDescription)
        parentCoordinator?.resetToInitialView()
    }
}

#if DEBUG
extension RecipesListCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
