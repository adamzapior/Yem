//
//  AddRecipeRouter.swift
//  Yem
//
//  Created by Adam Zapiór on 07/12/2023.
//

import Foundation
import UIKit

class AddRecipeRouter: AddRecipeRouterProtocol {
    static func createModule(view: AddRecipeVC) -> UIViewController {
        let presenter: AddRecipePresenterProtocol & AddRecipeOutputInteractorProtocol = AddRecipePresenter()
        
        view.presenter = presenter
        view.presenter?.router = AddRecipeRouter()
        view.presenter?.view = view
        view.presenter?.interactor = AddRecipeInteractor()
        view.presenter?.interactor?.presenter = presenter
        
        return view
    }
}
