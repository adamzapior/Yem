//
//  AddRecipeProtocols.swift
//  Yem
//
//  Created by Adam Zapiór on 07/12/2023.
//

import Foundation
import UIKit


protocol AddRecipeViewProtocol: AnyObject {
    // presenter -? view
    
    var presenter: AddRecipePresenterProtocol? { get set }
}

// presenter: view -> presenter
protocol AddRecipePresenterProtocol {
    var interactor: AddRecipeInputInteractorProtocol? { get set }
    var view: AddRecipeViewProtocol? { get set }
    var router: AddRecipeRouterProtocol? { get set }
    
    func viewDidLoad()
}

protocol AddRecipeInputInteractorProtocol {
    var presenter: AddRecipeOutputInteractorProtocol? { get set }
    
    // presenter -> interactor
///    func getRecipesList()
}


protocol AddRecipeOutputInteractorProtocol {
    // interactor -> presenter
///    func recipesListDidFetch()
}

// presenter -> router
protocol AddRecipeRouterProtocol  {
    static func createModule(view: AddRecipeVC) -> UIViewController
//    func pushToAddRecipeView(from view: UIViewController)
}

