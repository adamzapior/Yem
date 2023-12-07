//
//  RecipesListVC.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import UIKit

class RecipesListVC: UIViewController, RecipesListViewProtocol {
    
    var presenter: RecipesListPresenterProtocol?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground

        // NavigationBar
        navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRecipeButtonTapped))
        self.navigationItem.rightBarButtonItem?.tintColor = .orange

        
    }
    
    func showRecipes() {
        //
    }
    
    @objc func addRecipeButtonTapped() {
        presenter?.goToAddRecipe(from: self)
      }
    
}
