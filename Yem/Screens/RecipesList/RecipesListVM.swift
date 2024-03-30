//
//  RecipesListVM.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import Combine
import Foundation
import Kingfisher
import UIKit
import LifetimeTracker

protocol RecipesListVMDelegate: AnyObject {
    func reloadTable()
}

final class RecipesListVM {
    weak var delegate: RecipesListVMDelegate?
    let repository: DataRepository
    
    var sections: [Section] = []
    var recipes: [RecipeModel] = []
    
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
        
#if DEBUG
        trackLifetime()
#endif
    }
    
    // MARK: - Public methods
    
    func loadRecipes() {
        let result = repository.fetchAllRecipes()
        switch result {
        case .success(let result):
            DispatchQueue.main.async {
                self.recipes = result
                self.groupRecipesByCategory()
                self.reloadTable()
            }
        case .failure(let error):
            print("DEBUG: Error loading recipes: \(error)")
        }
    }

    // MARK: - Private methods

    private func groupRecipesByCategory() {
        sections.removeAll()
        
        let groupedRecipes = Dictionary(grouping: recipes, by: { $0.category })
        
        for category in RecipeCategory.allCases {
            let recipesForCategory = groupedRecipes[category] ?? []
            let section = Section(title: RecipeCategory(rawValue: category.rawValue) ?? .notSelected, items: recipesForCategory)
            sections.append(section)
        }
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

struct Section {
    let title: RecipeCategory
    let items: [RecipeModel]
}

#if DEBUG
extension RecipesListVM: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewModels")
    }
}
#endif
