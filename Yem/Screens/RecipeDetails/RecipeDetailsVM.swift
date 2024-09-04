//
//  RecipeDetailsVM.swift
//  Yem
//
//  Created by Adam Zapiór on 20/02/2024.
//

import Combine
import Foundation
import Kingfisher
import LifetimeTracker
import UIKit

final class RecipeDetailsVM {
    private let repository: DataRepositoryProtocol
    private let localFileManager: LocalFileManagerProtocol
    private let imageFetcher: ImageFetcherManagerProtocol

    var recipe: RecipeModel
    var isFavourite: Bool

    let inputEvent = PassthroughSubject<Input, Never>()
    private var inputPublisher: AnyPublisher<Input, Never> {
        inputEvent.eraseToAnyPublisher()
    }

    private let outputEvent = PassthroughSubject<Output, Never>()
    var outputPublisher: AnyPublisher<Output, Never> {
        outputEvent.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()

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

        observeInput()

#if DEBUG
        trackLifetime()
#endif
    }

    func loadRecipeImage(recipe: RecipeModel, completion: @escaping (UIImage?) -> Void) {
        guard recipe.isImageSaved else {
            completion(nil)
            return
        }

        let imageUrlResult = localFileManager.imageUrl(for: recipe.id.uuidString)

        switch imageUrlResult {
        case .success(let imageUrl):
            imageFetcher.fetchImage(from: imageUrl) { result in
                switch result {
                case .success(let image):
                    completion(image)
                case .failure(let error):
                    completion(nil)
                    print("Error fetching image: \(error.localizedDescription)")
                }
            }
        case .failure(let error):
            print("Error retrieving image URL: \(error.localizedDescription)")
        }
    }
    
    // Methods used in NavBar items : 

    func toggleFavouriteStatus() {
        let newFavouriteStatus = !recipe.isFavourite
        repository.updateRecipeFavouriteStatus(recipeId: recipe.id, isFavourite: newFavouriteStatus)
        recipe.isFavourite = newFavouriteStatus
        isFavourite = newFavouriteStatus
        outputEvent.send(.recipeFavouriteValueChanged(to: newFavouriteStatus))
    }

    func addIngredientsToShopingList() {
        repository.addIngredientsToShoppingList(ingredients: recipe.ingredientList)
    }

    func deleteRecipe() {
        repository.deleteRecipe(withId: recipe.id)
    }
}

// MARK: - Observed Input

extension RecipeDetailsVM {
    private func observeInput() {
        inputPublisher
            .sink { [unowned self] event in
                switch event {
                case .viewDidLoad:
                    self.loadRecipeImage(recipe: recipe) { image in
                        guard let image = image else { return }
                        self.outputEvent.send(.updatePhoto(image))
                    }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Input & Output Definitions

extension RecipeDetailsVM {
    enum Input {
        case viewDidLoad
    }

    enum Output {
        case updatePhoto(UIImage)
        case recipeFavouriteValueChanged(to: Bool)
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension RecipeDetailsVM: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewModels")
    }
}
#endif
