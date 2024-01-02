//
//  AddRecipeCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import UIKit

final class AddRecipeCoordinator {
    var parentCoordinator: RecipesListCoordinator?
    var viewModel: AddRecipeViewModel
    weak var navigationController: UINavigationController?

    // Konstruktor przyjmuje UINavigationController.
    init(navigationController: UINavigationController?, viewModel: AddRecipeViewModel) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }

    func start() -> UIViewController {
        let addRecipeVC = AddRecipeVC(coordinator: self, viewModel: viewModel)
        return addRecipeVC
    }

    func goToRecipeIngredientsVC() {
        let controller = AddRecipeIngredientsVC(viewModel: viewModel, coordinator: self)
        navigationController?.pushViewController(controller, animated: true)
    }

    func openIngredientSheet() {
        let controller = AddIngredientSheetVC(viewModel: viewModel, coordinator: self)
        navigationController?.present(controller, animated: true)
    }
    
    func goToInstructionsVC() {
        let controller = AddRecipeInstructionsVC(viewModel: viewModel, coordinator: self)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: Dissmis view controller

    func dismissVC() {
        navigationController?.dismiss(animated: true)
    }
    
    func dismissVCStack() {
        navigationController?.popToRootViewController(animated: true)
    }
}
