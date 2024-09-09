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

final class RecipesListVM {
    let localFileManager: LocalFileManagerProtocol
    let imageFetcherManager: ImageFetcherManagerProtocol
    private let repository: DataRepositoryProtocol
   
    var sections: [Section] = []
    
    var recipes: [RecipeModel] = []
    var filteredRecipes: [RecipeModel] = []
    
    @Published var currentQuery: String = ""
    
    // MARK: Input events
    
    let inputRecipesListEvent = PassthroughSubject<RecipesListInput, Never>()
    let inputSearchResultsEvent = PassthroughSubject<RecipesSearchResultInput, Never>()

    // MARK: Input publishers
    
    private var inputRecipesListEventPublisher: AnyPublisher<RecipesListInput, Never> {
        inputRecipesListEvent.eraseToAnyPublisher()
    }
    
    private var inputSearchResultsPublisher: AnyPublisher<RecipesSearchResultInput, Never> {
        inputSearchResultsEvent.eraseToAnyPublisher()
    }
    
    // MARK: Output events
    
    private let outputRecipesListEvent = PassthroughSubject<RecipesListOutput, Never>()
    private let outputSearchResultsEvent = PassthroughSubject<RecipesSearchResultOutput, Never>()

    // MARK: Output publishers
    
    var outputPublisher: AnyPublisher<RecipesListOutput, Never> {
        outputRecipesListEvent.eraseToAnyPublisher()
    }

    var outputSearchResultsPublisher: AnyPublisher<RecipesSearchResultOutput, Never> {
        outputSearchResultsEvent.eraseToAnyPublisher()
    }

    private var cancellables: Set<AnyCancellable> = []
    
    init(
        repository: DataRepositoryProtocol,
        localFileManager: LocalFileManagerProtocol,
        imageFetcherManager: ImageFetcherManagerProtocol
    ) {
        self.repository = repository
        self.localFileManager = localFileManager
        self.imageFetcherManager = imageFetcherManager
        
        observeRepositoryPublishers()
        observeRecipesListInput()
        observeSearchableQuery()
        observeRecipesSearchResultsInput()
        
#if DEBUG
        trackLifetime()
#endif
    }
    
    // MARK: - Fetch methods
    
    func loadRecipes() {
        Task {
            do {
                let recipes = try repository.fetchAllRecipes()
                self.recipes = recipes
                self.groupRecipesByCategory()
                outputRecipesListEvent.send(.initialDataFetched)
                outputRecipesListEvent.send(.updateListStatus(isEmpty: recipes.isEmpty))
                outputRecipesListEvent.send(.reloadTable)
            } catch {
                print("DEBUG: Error loading recipes: \(error.localizedDescription)")
            }
        }
    }
    
    func reloadRecipesList() {
        Task {
            do {
                let recipes = try repository.fetchAllRecipes()
                self.recipes = recipes
                self.groupRecipesByCategory()
                outputRecipesListEvent.send(.updateListStatus(isEmpty: recipes.isEmpty))
                outputRecipesListEvent.send(.reloadTable)
            } catch {
                print("DEBUG: Error loading recipes: \(error.localizedDescription)")
            }
        }
    }

    
    // MARK: - Private methods

    private func groupRecipesByCategory() {
        sections.removeAll()
        
        let groupedRecipes = Dictionary(grouping: recipes, by: { $0.category })
        
        for category in RecipeCategory.allCases {
            if let recipesForCategory = groupedRecipes[category], !recipesForCategory.isEmpty {
                let section = Section(title: category, items: recipesForCategory)
                sections.append(section)
            }
        }
    }
    
    private func filterRecipes(query: String) {
        if query.isEmpty {
            filteredRecipes = recipes
        } else {
            filteredRecipes = recipes.filter { $0.name.lowercased().contains(query.lowercased()) }
        }
    }
}

// MARK: Observed repository publishers

extension RecipesListVM {
    private func observeRepositoryPublishers() {
        repository.recipesInsertedPublisher
            .sink(receiveValue: { [unowned self] _ in
                Task {
                    self.reloadRecipesList()
                }
            })
            .store(in: &cancellables)
        
        repository.recipesUpdatedPublisher
            .sink(receiveValue: { [unowned self] _ in
                Task {
                    self.reloadRecipesList()
                }
            })
            .store(in: &cancellables)
        
        repository.recipesDeletedPublisher
            .sink(receiveValue: { [unowned self] _ in
                Task {
                    self.reloadRecipesList()
                }
            })
            .store(in: &cancellables)
    }
}

// MARK: - Observed properties

extension RecipesListVM {
    private func observeSearchableQuery() {
        $currentQuery
            .sink { [unowned self] newValue in
                filterRecipes(query: newValue)
                outputSearchResultsEvent.send(.updateListStatus(isEmpty: filteredRecipes.isEmpty))
                outputSearchResultsEvent.send(.reloadTable)
            }
            .store(in: &cancellables)
    }
}

// MARK: Observed Input

extension RecipesListVM {
    private func observeRecipesListInput() {
        inputRecipesListEventPublisher
            .sink { [unowned self] event in
                switch event {
                case .viewDidLoad:
                    loadRecipes()
                }
            }
            .store(in: &cancellables)
    }
    
    private func observeRecipesSearchResultsInput() {
        inputSearchResultsPublisher
            .sink { [unowned self] event in
                switch event {
                case .viewDidLoad:
                    outputSearchResultsEvent.send(.updateListStatus(isEmpty: filteredRecipes.isEmpty))
                case .sendQueryValue(let value):
                    currentQuery = value
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Input & Output - definition for ViewModel & RecipesListVC

extension RecipesListVM {
    enum RecipesListInput {
        case viewDidLoad
    }
    
    enum RecipesListOutput {
        case reloadTable
        case initialDataFetched
        case updateListStatus(isEmpty: Bool)
    }
}

// MARK: - Input & Output - definition for ViewModel & RecipesSearchResultsVC

extension RecipesListVM {
    enum RecipesSearchResultInput {
        case viewDidLoad
        case sendQueryValue(String)
    }
    
    enum RecipesSearchResultOutput {
        case reloadTable
        case updateListStatus(isEmpty: Bool)
    }
}

// MARK: - Helper enums

extension RecipesListVM {
    struct Section {
        let title: RecipeCategory
        let items: [RecipeModel]
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension RecipesListVM: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewModels")
    }
}
#endif
