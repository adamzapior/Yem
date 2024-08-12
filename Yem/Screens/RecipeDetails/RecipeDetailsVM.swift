//
//  RecipeDetailsVM.swift
//  Yem
//
//  Created by Adam Zapiór on 20/02/2024.
//

import Foundation
import Kingfisher
import LifetimeTracker
import UIKit

protocol RecipeDetailsVMDelegate: AnyObject {
    func isFavouriteValueChanged(to: Bool)
}

final class RecipeDetailsVM {
    weak var delegate: RecipeDetailsVMDelegate?

    let repository: DataRepositoryProtocol
    let localFileManager: LocalFileManagerProtocol
    let imageFetcher: ImageFetcherManagerProtocol

    var recipe: RecipeModel
    var isFavourite: Bool

    init(
        recipe: RecipeModel,
        repository: DataRepositoryProtocol,
        localFileManager: LocalFileManagerProtocol,
        imageFetcher: ImageFetcherManagerProtocol
    ) {
        self.recipe = recipe
        self.repository = repository
        self.localFileManager = localFileManager
        self.imageFetcher = imageFetcher

        isFavourite = recipe.isFavourite

        print(recipe.isImageSaved.description)

#if DEBUG
        trackLifetime()
#endif
    }

    deinit {
        print("DEBUG: RecipeDetailsVM deinit")
    }

    func loadRecipeImage(recipe: RecipeModel, completion: @escaping (UIImage?) -> Void) {
        guard recipe.isImageSaved else {
            completion(nil)
            return
        }

        let imageUrl = localFileManager.imageUrl(for: recipe.id.uuidString)
        guard let imageUrl = imageUrl else {
            completion(nil)
            return
        }

        imageFetcher.fetchImage(from: imageUrl, completion: completion)
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

#if DEBUG
extension RecipeDetailsVM: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewModels")
    }
}
#endif
