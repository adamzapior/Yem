//
//  AddRecipeCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import LifetimeTracker
import UIKit

final class AddRecipeCoordinator: ChildCoordinator {
    var parentCoordinator: AddRecipeParentCoordinator?
    var viewControllerRef: UIViewController?
    var navigationController: UINavigationController

    var viewModel: AddRecipeViewModel

    init(navigationController: UINavigationController, viewModel: AddRecipeViewModel, parentCoordinator: AddRecipeParentCoordinator) {
        self.navigationController = navigationController
        self.viewModel = viewModel
        self.parentCoordinator = parentCoordinator

#if DEBUG
        trackLifetime()
#endif
    }

    func start(animated: Bool) {
        let addRecipeVC = AddRecipeVC(coordinator: self, viewModel: viewModel)
        viewControllerRef = addRecipeVC
        addRecipeVC.hidesBottomBarWhenPushed = true
        navigationController.customPushViewController(viewController: addRecipeVC)
    }

    func coordinatorDidFinish() {
        if let viewController = viewControllerRef as? DisposableViewController {
            viewController.cleanUp()
        }

        parentCoordinator?.childDidFinish(self)
        viewControllerRef = nil
        parentCoordinator = nil
        print("DEBUG: AddRecipeCoordinator: coordinatorDidFinish() called")
    }

    func pushVC(for route: AddRecipeRoute) {
        let viewModel = viewModel
        switch route {
        case .ingredientsList:
            let controller = AddRecipeIngredientsVC(viewModel: viewModel, coordinator: self)
            navigationController.pushViewController(controller, animated: true)
        case .addIngredient:
            let controller = AddIngredientSheetVC(viewModel: viewModel, coordinator: self)
            navigationController.present(controller, animated: true)
        case .instructions:
            let controller = AddRecipeInstructionsVC(viewModel: viewModel, coordinator: self)
            navigationController.pushViewController(controller, animated: true)
        case .addInstruction:
            let controller = AddInstructionSheetVC(viewModel: viewModel, coordinator: self)
            navigationController.present(controller, animated: true)
        }
    }

    func presentValidationAlert(title: String, message: String) {
        let alertVC = ValidationAlertVC(title: title, message: message)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        navigationController.present(alertVC, animated: true, completion: nil)
    }

    func dismissVC() {
        navigationController.dismiss(animated: true)
    }

    func dismissVCStack() {
        navigationController.popToRootViewController(animated: true)
    }
}

enum AddRecipeRoute {
    case ingredientsList
    case addIngredient
    case instructions
    case addInstruction
}

protocol AddRecipeParentCoordinator {
    func childDidFinish(_ child: Coordinator)
}

extension RecipesListCoordinator: AddRecipeParentCoordinator {}

#if DEBUG
extension AddRecipeCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
