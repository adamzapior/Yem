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
