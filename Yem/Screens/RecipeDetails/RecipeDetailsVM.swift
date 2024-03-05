//
//  RecipeDetailsVM.swift
//  Yem
//
//  Created by Adam Zapiór on 20/02/2024.
//

import Foundation

protocol RecipeDetailsVMDelegate: AnyObject {
    func isFavouriteValueChanged(to: Bool)
}

final class RecipeDetailsVM {
    
    weak var delegate: RecipeDetailsVMDelegate?
    
    let recipe: RecipeModel
    let repository: DataRepository
    
    init(recipe: RecipeModel, repository: DataRepository) {
        self.recipe = recipe
        self.repository = repository
    }
    
    deinit {
        print("DEBUG: RecipeDetailsVM deinit")
    }
    
    func toggleFavouriteStatus(recipe: RecipeModel) {
        switch recipe.isFavourite {
        case true:
            repository.updateRecipeFavouriteStatus(recipeId: recipe.id, isFavourite: false)
            delegate?.isFavouriteValueChanged(to: false)
        case false:
            repository.updateRecipeFavouriteStatus(recipeId: recipe.id, isFavourite: true)
            delegate?.isFavouriteValueChanged(to: true)
        }
    }
    
    func deleteRecipe(_ recipe: RecipeModel) {
        repository.deleteRecipe(withId: recipe.id)
    }
    
}
