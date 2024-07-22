//
//  IngredientViewModelProtocol.swift
//  Yem
//
//  Created by Adam Zapiór on 11/06/2024.
//

import Foundation

protocol IngredientViewModel {
    var delegateIngredients: AddRecipeIngredientsVCDelegate? { get set }
    var delegateIngredientSheet: AddIngredientSheetVCDelegate? { get set }
    var ingredientName: String { get set }
    var ingredientValue: String { get set }
    var ingredientValueType: String { get set }
    var valueTypeArray: [String] { get }
    func addIngredientToList() -> Bool
}

protocol Coordinator {
    func dismissSheet()
}
