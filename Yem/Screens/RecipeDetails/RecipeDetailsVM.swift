//
//  RecipeDetailsVM.swift
//  Yem
//
//  Created by Adam Zapiór on 20/02/2024.
//

import Foundation
import UIKit

protocol RecipeDetailsVMDelegate: AnyObject {
    func isFavouriteValueChanged(to: Bool)
}

final class RecipeDetailsVM {
    
    weak var delegate: RecipeDetailsVMDelegate?
    
    var recipe: RecipeModel
    let repository: DataRepository
    
    var isFavourite: Bool
    
    init(recipe: RecipeModel, repository: DataRepository) {
        self.recipe = recipe
        self.repository = repository
        
        isFavourite = recipe.isFavourite
    }
    
    deinit {
        print("DEBUG: RecipeDetailsVM deinit")
    }
    
    func loadRecipeImage() async -> UIImage? {
        guard recipe.isImageSaved else {
            return nil
        }

        do {
            return await LocalFileManager.instance.loadImageAsync(with: recipe.id.uuidString)
        }
    }
    
    func toggleFavouriteStatus() {
        let newFavouriteStatus = !recipe.isFavourite
        repository.updateRecipeFavouriteStatus(recipeId: recipe.id, isFavourite: newFavouriteStatus)
        recipe.isFavourite = newFavouriteStatus
        self.isFavourite = newFavouriteStatus
        delegate?.isFavouriteValueChanged(to: newFavouriteStatus)
    }

    func addIngredientsToShopingList() {
        repository.addIngredientsToShopingList(ingredients: recipe.ingredientList)
    }

    func deleteRecipe() {
        repository.deleteRecipe(withId: recipe.id)
    }

    
}
