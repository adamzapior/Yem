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
    
    lazy var recipes: [RecipeModel] = []
    private var cancellables: Set<AnyCancellable> = []

    init(repository: DataRepository) {
        self.repository = repository

        repository.recipesChangedPublisher
            .sink(receiveValue: { [weak self] _ in
                Task { [weak self] in
                    await self?.loadRecipes()
                }
            })
            .store(in: &cancellables)
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
}

// MARK: - Delegates

extension RecipesListVM: RecipesListVMDelegate {
    func reloadTable() {
        DispatchQueue.main.async {
            self.delegate?.reloadTable()
        }
    }
}
