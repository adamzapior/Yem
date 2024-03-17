//
//  RecipesListVM.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import Combine
import Foundation
import UIKit

protocol RecipesListVMDelegate: AnyObject {
    func reloadTable()
}

final class RecipesListVM {
    weak var delegate: RecipesListVMDelegate?
    let repository: DataRepository
    
    lazy var recipes: [RecipeModel] = []
    private var cancellables: Set<AnyCancellable> = []

    init(repository: DataRepository) {
        self.repository = repository
        
        repository.recipesInsertedPublisher
            .sink(receiveValue: { [weak self] _ in
                Task { [weak self] in
                    self?.loadRecipes()
                }
            })
            .store(in: &cancellables)

        
        repository.recipesUpdatedPublisher
            .sink(receiveValue: { [weak self] _ in
                Task { [weak self] in
                    self?.loadRecipes()
                }
            })
            .store(in: &cancellables)
        
        repository.recipesDeletedPublisher
            .sink(receiveValue: { [weak self] _ in
                Task { [weak self] in
                    self?.loadRecipes()
                }
            })
            .store(in: &cancellables)

    }

    // MARK: - Public methods

    func loadRecipes() {
        let result = repository.fetchAllRecipes()
        switch result {
        case .success(let result):
            DispatchQueue.main.async {
                self.recipes = result
                self.reloadTable()
            }
        case .failure(let error):
            print("Error loading recipes: \(error)")
        }
    }
    
    func loadRecipeImage(recipe: RecipeModel) async -> UIImage? {
        guard recipe.isImageSaved else {
            return nil
        }

        do {
            return await LocalFileManager.instance.loadImageAsync(with: recipe.id.uuidString)
        }
    }
    

    // MARK: - Private methods
}

// MARK: - Delegates

extension RecipesListVM: RecipesListVMDelegate {
    func reloadTable() {
        DispatchQueue.main.async {
            self.delegate?.reloadTable()
        }
    }
}
