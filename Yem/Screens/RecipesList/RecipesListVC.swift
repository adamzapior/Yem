//
//  RecipesListVC.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import UIKit

import UIKit

class RecipesListVC: UIViewController {
    var vm = RecipesListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // NavigationBar setup
        setupNavigationBar()
        
        vm.getRecipesList()
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRecipeButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = .orange
    }
    
    //    func showRecipes(recipes: [Recipe]) {
    //        // Update UI with recipes
    //    }
}

extension RecipesListVC {
    @objc func addRecipeButtonTapped() {
        addRecipe()
    }
    
    func addRecipe() {
        let recipeView = AddRecipeVC()
        goToAddRecipeScreen(from: self, toView: recipeView)
    }
    
    func goToAddRecipeScreen(from view: UIViewController, toView: UIViewController) {
        toView.hidesBottomBarWhenPushed = true
        view.navigationController?.pushViewController(toView, animated: true)
    }
}
