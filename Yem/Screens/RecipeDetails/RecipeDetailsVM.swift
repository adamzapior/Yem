//
//  RecipeDetailsVM.swift
//  Yem
//
//  Created by Adam Zapiór on 20/02/2024.
//

import Foundation
import Kingfisher
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

    func loadRecipeImage(recipe: RecipeModel, completion: @escaping (UIImage?) -> Void) {
        guard recipe.isImageSaved else {
            completion(nil)
            return
        }
    
        let imageUrl = LocalFileManager.instance.imageUrl(for: recipe.id.uuidString)
        let provider = LocalFileImageDataProvider(fileURL: imageUrl!)
        let newImage = UIImageView()
    
        newImage.kf.setImage(with: provider) { result in
            switch result {
            case .success(let result):
                DispatchQueue.main.async {
                    completion(result.image)
                }
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func toggleFavouriteStatus() {
        let newFavouriteStatus = !recipe.isFavourite
        repository.updateRecipeFavouriteStatus(recipeId: recipe.id, isFavourite: newFavouriteStatus)
        recipe.isFavourite = newFavouriteStatus
        isFavourite = newFavouriteStatus
        delegate?.isFavouriteValueChanged(to: newFavouriteStatus)
    }

    func addIngredientsToShopingList() {
        repository.addIngredientsToShopingList(ingredients: recipe.ingredientList)
    }

    func deleteRecipe() {
        repository.deleteRecipe(withId: recipe.id)
    }
}
