//
//  RecipesListVM.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import Foundation

protocol RecipesListVMDelegate: AnyObject {
    func reloadTable()
}

class RecipesListVM {
    weak var delegate: RecipesListVMDelegate?
    let repository: DataRepository

    lazy var recipes: [RecipeModel] = []

    init(repository: DataRepository) {
        self.repository = repository
    }

    func loadRecipes() async {
        let result = await repository.fetchAllRecipes()
        switch result {
        case .success:
            _ = result.map { success in
                self.recipes = success
            }
            
            for x in recipes {
//                print(x.instructionList.first)
            }
            
            reloadTable()
        case .failure:
            break
        }
    }
    
    func searchRecipesByName(_ query: String) async {
        let result = await repository.fetchRecipesWithName(query)
        switch result {
        case .success(let recepies):
            self.recipes = recipes
            reloadTable()
        case .failure:
            break
        }
    }
}

// MARK: Delegate

extension RecipesListVM: RecipesListVMDelegate {
    func reloadTable() {
        DispatchQueue.main.async {
            self.delegate?.reloadTable()
        }
    }
}
