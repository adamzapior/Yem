//
//  RecipesListVM.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import Combine
import Foundation

protocol RecipesListVMDelegate: AnyObject {
    func reloadTable()
}

final class RecipesListVM {
    weak var delegate: RecipesListVMDelegate?
    let repository: DataRepository
    private var cancellables: Set<AnyCancellable> = []

    lazy var recipes: [RecipeModel] = []

    init(repository: DataRepository) {
        self.repository = repository
        observeDataChanges()
    }

    // MARK: - Public methods

    func loadRecipes() async {
        let result = await repository.fetchAllRecipes()
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

    // MARK: - Private methods

    private func observeDataChanges() {
        repository.observeDataChanges()
            .sink { [weak self] updatedRecipes in
                guard let self = self else { return }

                // Create a dictionary for quick access
                let updatedRecipesDict = Dictionary(uniqueKeysWithValues: updatedRecipes.map { ($0.id, $0) })

                // Update existing recipes or add new ones
                self.recipes = self.recipes.compactMap { existingRecipe -> RecipeModel? in
                    updatedRecipesDict[existingRecipe.id] ?? existingRecipe
                }

                // Add new recipes that are not already in `recipes`
                updatedRecipes.forEach { updatedRecipe in
                    if !self.recipes.contains(where: { $0.id == updatedRecipe.id }) {
                        self.recipes.append(updatedRecipe)
                    }
                }

                self.reloadTable()
                print("RecipesList view refreshed")
            }
            .store(in: &cancellables)
    }
}

// MARK: - Delegates

extension RecipesListVM: RecipesListVMDelegate {
    func reloadTable() {
        DispatchQueue.main.async {
            self.delegate?.reloadTable()
        }
    }
}
