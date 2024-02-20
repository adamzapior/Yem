//
//  RecipeDetailsVC.swift
//  Yem
//
//  Created by Adam Zapiór on 20/02/2024.
//

import UIKit

class RecipeDetailsVC: UIViewController {
    let recipe: RecipeModel
    
    let viewModel: RecipeDetailsVM
    let coordinator: RecipeDetailsCoordinator

    init(recipe: RecipeModel, viewModel: RecipeDetailsVM, coordinator: RecipeDetailsCoordinator) {
        self.recipe = recipe
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
    }
}
