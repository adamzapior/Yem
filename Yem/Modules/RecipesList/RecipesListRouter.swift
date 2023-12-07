//
//  RecipesListRouter.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import Foundation
import UIKit

class RecipesListRouter: RecipesListRouterProtocol {
    static func createModule(view: RecipesListVC) -> UIViewController {
        let presenter: RecipesListPresenterProtocol & RecipesListOutputInteractorProtocol = RecipesListPresenter()
        
        view.presenter = presenter
        view.presenter?.router = RecipesListRouter()
        view.presenter?.view = view
        view.presenter?.interactor = RecipesListInteractor()
        view.presenter?.interactor?.presenter = presenter
        
        return view
    }
    
    func pushToAddRecipeView(from view: UIViewController) {
        let recipeView = AddRecipeRouter.createModule(view: AddRecipeVC())
//
        view.navigationController?.pushViewController(recipeView, animated: true)
    }
    
}
