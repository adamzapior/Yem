//
//  RecipesListVC.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import UIKit

import UIKit

final class RecipesListVC: UIViewController {
    var coordinator: RecipesListCoordinator
    var viewModel: RecipesListVM
    
    // MARK: - Lifecycle
    
    init(coordinator: RecipesListCoordinator, viewModel: RecipesListVM) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        
        Task {
            await viewModel.loadRecipes()
            
            await viewModel.searchRecipesByName("XD")
        }
    }
    
    // MARK: UI Setup
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRecipeButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = .orange
    }
}

    // MARK: - Navigation

extension RecipesListVC {
    @objc func addRecipeButtonTapped() {
        coordinator.goToAddRecipeScreen()
    }
}
