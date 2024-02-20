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
    var viewModel: RecipeDetailsVM
    weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?, viewModel: RecipeDetailsVM, recipe: RecipeModel) {
        self.navigationController = navigationController
        self.viewModel = viewModel
        self.recipe = recipe
    }

    func start() -> UIViewController {
        let detailsVC = RecipeDetailsVC(recipe: recipe, viewModel: viewModel, coordinator: self)
        return detailsVC
    }

}
