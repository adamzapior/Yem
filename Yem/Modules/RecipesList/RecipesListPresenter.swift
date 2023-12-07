//
//  RecipesListPresenter.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import Foundation
import UIKit

class RecipesListPresenter: RecipesListPresenterProtocol {
    
    var interactor: RecipesListInputInteractorProtocol?
    weak var view: RecipesListViewProtocol?
    var router: RecipesListRouterProtocol?
    
    func viewDidLoad() {
        //
    }
    
    func goToAddRecipe(from view: UIViewController) {
        router?.pushToAddRecipeView(from: view)
    }
    
}

extension RecipesListPresenter: RecipesListOutputInteractorProtocol {
    func recipesListDidFetch() {
        //
    }
    
    
}
