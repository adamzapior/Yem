//
//  AddRecipePresenter.swift
//  Yem
//
//  Created by Adam Zapiór on 07/12/2023.
//

import Foundation


class AddRecipePresenter: AddRecipePresenterProtocol {
    var interactor: AddRecipeInputInteractorProtocol?
    weak var view: AddRecipeViewProtocol?
    var router: AddRecipeRouterProtocol?
    
    func viewDidLoad() {
        //
    }
    
    
}

extension AddRecipePresenter: AddRecipeOutputInteractorProtocol {

    
}
