//
//  AddRecipeCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import UIKit


final class AddRecipeCoordinator {
    var parentCoordinator: AddRecipeParentCoordinator?
    var viewModel: AddRecipeViewModel
    weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?, viewModel: AddRecipeViewModel) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }

    func start() -> UIViewController {
        let addRecipeVC = AddRecipeVC(coordinator: self, viewModel: viewModel)
        return addRecipeVC
    }

    func pushVC(for route: AddRecipeRoute) {
        let viewModel = viewModel
        switch route {
        case .ingredientsList:
            let controller = AddRecipeIngredientsVC(viewModel: viewModel, coordinator: self)
            navigationController?.pushViewController(controller, animated: true)
        case .addIngredient:
            let controller = AddIngredientSheetVC(viewModel: viewModel, coordinator: self)
            navigationController?.present(controller, animated: true)
        case .instructions:
            let controller = AddRecipeInstructionsVC(viewModel: viewModel, coordinator: self)
            navigationController?.pushViewController(controller, animated: true)
        case .addInstruction:
            let controller = AddInstructionSheetVC(viewModel: viewModel, coordinator: self)
            navigationController?.present(controller, animated: true)
        }
    }

    func presentValidationAlert(title: String, message: String) {
        let alertVC = ValidationAlertVC(title: title, message: message)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        navigationController?.present(alertVC, animated: true, completion: nil)
    }

    func dismissVC() {
        navigationController?.dismiss(animated: true)
    }

    func dismissVCStack() {
        navigationController?.popToRootViewController(animated: true)
    }
}

enum AddRecipeRoute {
    case ingredientsList
    case addIngredient
    case instructions
    case addInstruction
}

protocol AddRecipeParentCoordinator {
    // Define common functionalities or properties here
}

// Extend your existing coordinators to conform to this protocol
extension RecipesListCoordinator: AddRecipeParentCoordinator {
}

extension RecipeDetailsCoordinator: AddRecipeParentCoordinator {
    // Implement any required methods or properties
}
