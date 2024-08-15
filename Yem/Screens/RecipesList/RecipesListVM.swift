//
//  RecipesListVM.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import Combine
import Foundation
import Kingfisher
import LifetimeTracker
import UIKit

protocol RecipesListVMDelegate: AnyObject {
    func reloadTable()
}

protocol RecipesSearchResultDelegate: AnyObject {
    func reloadTable()
}

final class RecipesListVM {
    weak var delegate: RecipesListVMDelegate?
    weak var delegateRecipesSearchResult: RecipesSearchResultDelegate?

    let repository: DataRepositoryProtocol
    let localFileManager: LocalFileManagerProtocol
    let imageFetcherManager: ImageFetcherManagerProtocol
    
    var sections: [Section] = []
    
    var recipes: [RecipeModel] = [] {
        didSet {
            filterRecipes(query: currentQuery)
        }
    }
    
    var filteredRecipes: [RecipeModel] = []
    
    private var currentQuery: String = ""
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        repository: DataRepositoryProtocol,
        localFileManager: LocalFileManagerProtocol,
        imageFetcherManager: ImageFetcherManagerProtocol
    ) {
        self.repository = repository
        self.localFileManager = localFileManager
        self.imageFetcherManager = imageFetcherManager
        
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
    
    func filterRecipes(query: String) {
        currentQuery = query
        if query.isEmpty {
            filteredRecipes = recipes
        } else {
            filteredRecipes = recipes.filter { $0.name.lowercased().contains(query.lowercased()) }
        }
        reloadSearchableTable()
    }

    // MARK: - Private methods

    private func groupRecipesByCategory() {
        sections.removeAll()
        
        let groupedRecipes = Dictionary(grouping: recipes, by: { $0.category })
        
        for category in RecipeCategory.allCases {
            if let recipesForCategory = groupedRecipes[category], !recipesForCategory.isEmpty {
                let section = Section(title: category, items: recipesForCategory)
                sections.append(section)
                print(section.title)
            }
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

extension RecipesListVM: RecipesSearchResultDelegate {
    func reloadSearchableTable() {
        DispatchQueue.main.async {
            self.delegateRecipesSearchResult?.reloadTable()
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
