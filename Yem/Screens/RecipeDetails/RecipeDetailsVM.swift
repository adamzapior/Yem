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

    func toggleFavouriteStatus() {
        Task {
            do {
                let newFavouriteStatus = !recipe.isFavourite
                try repository.updateRecipeFavouriteStatus(recipeId: recipe.id, isFavourite: newFavouriteStatus)
                recipe.isFavourite = newFavouriteStatus
                isFavourite = newFavouriteStatus
                outputEvent.send(.recipeFavouriteValueChanged(value: newFavouriteStatus))
            } catch {
                print("DEBUG: Error when updating favourite status: \(error)")
            }
        }
    }

    func addIngredientsToShopingList() {
        do {
            try repository.addIngredientsToShopingList(ingredients: recipe.ingredientList)
        } catch {
            print("DEBUG: Error adding ingredients to shoping list: \(error)")
        }
    }

    func deleteRecipe() {
        do {
            try repository.deleteRecipe(withId: recipe.id)

        } catch {
            print("DEBUG: Error with delete recipe method: \(error)")
        }
    }

    func loadRecipeImage(recipe: RecipeModel, completion: @escaping (UIImage?) -> Void) {
        guard recipe.isImageSaved else {
            completion(nil)
            return
        }
        
        if let imageUrl = localFileManager.imageUrl(for: recipe.id.uuidString) {
                imageFetcher.fetchImage(from: imageUrl) { [weak self] image in
                    guard self != nil else { return }
                    completion(image)
                }
            }
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

// MARK: - Input & Output definitions

extension RecipeDetailsVM {
    enum Input {
        case viewDidLoad
    }

    enum Output {
        case updatePhoto(UIImage)
        case recipeFavouriteValueChanged(value: Bool)
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
