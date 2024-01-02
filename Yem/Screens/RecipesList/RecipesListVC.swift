//
//  RecipesListVC.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import UIKit

import UIKit

class RecipesListVC: UIViewController {
    
    var coordinator: RecipesListCoordinator
    var viewModel: RecipesListVM
    
    init(coordinator: RecipesListCoordinator, viewModel: RecipesListVM) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        viewModel.getRecipesList()
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRecipeButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = .orange
    }
}

extension RecipesListVC {
    @objc func addRecipeButtonTapped() {
        addRecipe()
    }
    
    func addRecipe() {
        coordinator.goToAddRecipeScreen()
    }
    
    func goToAddRecipeScreen(from view: UIViewController, toView: UIViewController) {
        toView.hidesBottomBarWhenPushed = true
        view.navigationController?.pushViewController(toView, animated: true)
    }
}
