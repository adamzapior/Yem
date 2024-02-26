//
//  RecipeDetailsVM.swift
//  Yem
//
//  Created by Adam Zapiór on 20/02/2024.
//

import Foundation

final class RecipeDetailsVM {
    
    let repository: DataRepository
    
    init(repository: DataRepository) {
        self.repository = repository
    }
    
    func deleteRecipe(_ recipe: RecipeModel) {
        repository.deleteRecipe(withId: recipe.id)
    }
}
