//
//  RecipesListCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import LifetimeTracker
import UIKit

final class RecipesListCoordinator: ParentCoordinator, ChildCoordinator {
    var parentCoordinator: TabBarCoordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var viewControllerRef: UIViewController?
    
    lazy var rootViewController: UIViewController = .init()
    let repository: DataRepository
    var viewModel: RecipesListVM
    
    init(parentCoordinator: TabBarCoordinator? = nil, repository: DataRepository, viewModel: RecipesListVM, navigationController: UINavigationController) {
        self.parentCoordinator = parentCoordinator
        self.repository = repository
        self.viewModel = viewModel
        self.navigationController = navigationController
#if DEBUG
        trackLifetime()
#endif
    }
    
    func start(animated: Bool = false) {
        let recipesListController = RecipesListVC(coordinator: self, viewModel: viewModel)
        recipesListController.viewModel = viewModel
        
        viewControllerRef = recipesListController

        recipesListController.tabBarItem = UITabBarItem(title: "Recipes",
                                                        image: UIImage(systemName: "book"),
                                                        selectedImage: nil)
        
        navigationController.customPushViewController(viewController: recipesListController)
    }

    func coordinatorDidFinish() {
        if let viewController = viewControllerRef as? DisposableViewController {
            viewController.cleanUp()
        }
        if let index = childCoordinators.firstIndex(where: { $0 === self }) {
            childCoordinators.remove(at: index)
        }
//        parentCoordinator?.childDidFinish(self)
        
        print("Coordinator did finish")
    }
    
    func childDidFinish(_ child: Coordinator) {
        if let index = childCoordinators.firstIndex(where: { $0 === child }) {
            childCoordinators.remove(at: index)
        }
    }
    
    // MARK: Navigation
    
    func navigateToAddRecipeScreen() {
        let viewModel = AddRecipeViewModel(repository: repository)

        let coordinator = AddRecipeCoordinator(navigationController: navigationController, viewModel: viewModel, parentCoordinator: self)
        coordinator.parentCoordinator = self

        coordinator.start(animated: true)
        
//        (navigationController).pushViewController(addRecipeVC, animated: true)
    }
    
    func navigateToRecipeDetail(with recipe: RecipeModel) {
        let viewModel = RecipeDetailsVM(recipe: recipe, repository: repository)
        
        let coordinator = RecipeDetailsCoordinator(navigationController: navigationController, parentCoordinator: self, viewModel: viewModel, recipe: recipe, repository: repository)
        coordinator.parentCoordinator = self

        let detailsVC: () = coordinator.start(animated: true)
//        detailsVC.hidesBottomBarWhenPushed = true
        
//        navigationController.popToViewController(detailsVC, animated: true)
//        navigationController.pushViewController(detailsVC, animated: true)
    }
}

#if DEBUG
extension RecipesListCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
