//
//  RecipesListCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import LifetimeTracker
import UIKit

//class RecipesListTabCoordinator: Destination {
//    private weak var parentCoordinator: TabBarCoordinator?
//
//    let authManager: AuthenticationManager
//    let repository: DataRepository
//    var viewModel: RecipesListVM
//    
//    var tabNavigator: Navigator? = nil
//    
//    override func render() -> UIViewController {
//        let controller = UIViewController()
//        tabNavigator = Navigator(root: controller)
//        tabNavigator?.goTo(screen: RecipesListCoordinator(parentCoordinator: parentCoordinator, repository: repository, viewModel: viewModel, authManager: authManager))
//        return controller
//    }
//    
//    init(parentCoordinator: TabBarCoordinator?, repository: DataRepository, viewModel: RecipesListVM, authManager: AuthenticationManager) {
//        self.parentCoordinator = parentCoordinator
//        self.repository = repository
//        self.viewModel = viewModel
//        self.authManager = authManager
//    }
//}

final class RecipesListCoordinator: Destination {
    private weak var parentCoordinator: TabBarCoordinator?
        
    let authManager: AuthenticationManager
    let repository: DataRepository
    var viewModel: RecipesListVM
    
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
    
//    func start(animated: Bool = false) {
//        let recipesListController = RecipesListVC(coordinator: self, viewModel: viewModel)
//        recipesListController.viewModel = viewModel
//
//        viewControllerRef = recipesListController
//
//        recipesListController.tabBarItem = UITabBarItem(title: "Recipes",
//                                                        image: UIImage(systemName: "book"),
//                                                        selectedImage: nil)
//
//        navigationController.customPushViewController(viewController: recipesListController)
//    }

    
    // MARK: Navigation
    
    func navigateToAddRecipeScreen() {
//        let viewModel = AddRecipeViewModel(repository: repository)
//        let coordinator = AddRecipeCoordinator(navigationController: navigationController, viewModel: viewModel, parentCoordinator: self)
//        coordinator.start(animated: true)
    }
    
    func navigateToRecipeDetail(with recipe: RecipeModel) {
//        let viewModel = RecipeDetailsVM(recipe: recipe, repository: repository)
//        let coordinator = RecipeDetailsCoordinator(navigationController: navigationController, parentCoordinator: self, viewModel: viewModel, recipe: recipe, repository: repository)
//        coordinator.start(animated: true)
    }
    
    func navigateToSettings() {
//        let viewModel = SettingsViewModel(authManager: authManager)
//        let coordinator = SettingsCoordinator(parentCoordinator: self, viewControllerRef: nil, navigationController: navigationController, viewModel: viewModel)
//
//        coordinator.start(animated: true)
//        (navigationController).pushViewController(addRecipeVC, animated: true)
    }
}

#if DEBUG
extension RecipesListCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
