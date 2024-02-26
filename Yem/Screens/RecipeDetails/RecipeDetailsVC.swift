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
    
    private let deleteButton = UIButton()
    
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
        setupDeleteButton()
        
    }
    
    private func setupDeleteButton() {
        deleteButton.setTitle("Delete Recipe", for: .normal)
        deleteButton.backgroundColor = .systemRed
        deleteButton.addTarget(self, action: #selector(deleteRecipe), for: .touchUpInside)
        
        view.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func deleteRecipe() {
        viewModel.deleteRecipe(recipe)
        coordinator.dismissVC()
    }
}
