//
//  RecipesListProtocols.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import Foundation
import UIKit


protocol RecipesListViewProtocol: AnyObject {
    // presenter -? view
    
    var presenter: RecipesListPresenterProtocol? { get set }
    func showRecipes()
}

// presenter: view -> presenter
protocol RecipesListPresenterProtocol {
    var interactor: RecipesListInputInteractorProtocol? { get set }
    var view: RecipesListViewProtocol? { get set }
    var router: RecipesListRouterProtocol? { get set }
    
    func viewDidLoad()
    func goToAddRecipe(from view: UIViewController)
}

protocol RecipesListInputInteractorProtocol {
    var presenter: RecipesListOutputInteractorProtocol? { get set }
    
    // presenter -> interactor
    func getRecipesList()
}


protocol RecipesListOutputInteractorProtocol {
    // interactor -> presenter
    func recipesListDidFetch()
}

// presenter -> router
protocol RecipesListRouterProtocol  {
    static func createModule(view: RecipesListVC) -> UIViewController
    func pushToAddRecipeView(from view: UIViewController)}
