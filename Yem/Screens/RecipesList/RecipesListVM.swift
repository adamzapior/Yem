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

final class RecipesListVM {
    weak var delegate: RecipesListVMDelegate?
    let repository: DataRepository

    lazy var recipes: [RecipeModel] = [RecipeModel(id: UUID(), name: "gugu", serving: "gugu", perpTimeHours: "gugu", perpTimeMinutes: "gugu", spicy: "gugu", category: "gugu", difficulty: "gugu", ingredientList: [IngredientModel(id: UUID(), value: "saf", valueType: "asf", name: "asfsaf")], instructionList: [InstructionModel(index: 1, text: "gugugu")]), RecipeModel(id: UUID(), name: "gugu", serving: "gugu", perpTimeHours: "gugu", perpTimeMinutes: "gugu", spicy: "gugu", category: "gugu", difficulty: "gugu", ingredientList: [IngredientModel(id: UUID(), value: "saf", valueType: "asf", name: "asfsaf")], instructionList: [InstructionModel(index: 1, text: "gugugu")]), RecipeModel(id: UUID(), name: "gugu", serving: "gugu", perpTimeHours: "gugu", perpTimeMinutes: "gugu", spicy: "asfa", category: "gugu", difficulty: "gugu", ingredientList: [IngredientModel(id: UUID(), value: "saf", valueType: "asf", name: "asfsaf")], instructionList: [InstructionModel(index: 1, text: "gugugu")]), RecipeModel(id: UUID(), name: "gugu", serving: "gugu", perpTimeHours: "gugu", perpTimeMinutes: "gugu", spicy: "asfa", category: "gugu", difficulty: "gugu", ingredientList: [IngredientModel(id: UUID(), value: "saf", valueType: "asf", name: "asfsaf")], instructionList: [InstructionModel(index: 1, text: "gugugu")]), RecipeModel(id: UUID(), name: "gugu", serving: "gugu", perpTimeHours: "gugu", perpTimeMinutes: "gugu", spicy: "asfa", category: "gugu", difficulty: "gugu", ingredientList: [IngredientModel(id: UUID(), value: "saf", valueType: "asf", name: "asfsaf")], instructionList: [InstructionModel(index: 1, text: "gugugu")]), RecipeModel(id: UUID(), name: "gugu", serving: "gugu", perpTimeHours: "gugu", perpTimeMinutes: "gugu", spicy: "asfa", category: "gugu", difficulty: "gugu", ingredientList: [IngredientModel(id: UUID(), value: "saf", valueType: "asf", name: "asfsaf")], instructionList: [InstructionModel(index: 1, text: "gugugu")]), RecipeModel(id: UUID(), name: "gugu", serving: "gugu", perpTimeHours: "gugu", perpTimeMinutes: "gugu", spicy: "asfa", category: "gugu", difficulty: "gugu", ingredientList: [IngredientModel(id: UUID(), value: "saf", valueType: "asf", name: "asfsaf")], instructionList: [InstructionModel(index: 1, text: "gugugu")]), RecipeModel(id: UUID(), name: "gugu", serving: "gugu", perpTimeHours: "gugu", perpTimeMinutes: "gugu", spicy: "asfa", category: "gugu", difficulty: "gugu", ingredientList: [IngredientModel(id: UUID(), value: "saf", valueType: "asf", name: "asfsaf")], instructionList: [InstructionModel(index: 1, text: "gugugu")]), RecipeModel(id: UUID(), name: "gugu", serving: "gugu", perpTimeHours: "gugu", perpTimeMinutes: "gugu", spicy: "asfa", category: "gugu", difficulty: "gugu", ingredientList: [IngredientModel(id: UUID(), value: "saf", valueType: "asf", name: "asfsaf")], instructionList: [InstructionModel(index: 1, text: "gugugu")]), RecipeModel(id: UUID(), name: "gugu", serving: "gugu", perpTimeHours: "gugu", perpTimeMinutes: "gugu", spicy: "asfa", category: "gugu", difficulty: "gugu", ingredientList: [IngredientModel(id: UUID(), value: "saf", valueType: "asf", name: "asfsaf")], instructionList: [InstructionModel(index: 1, text: "gugugu")]), RecipeModel(id: UUID(), name: "gugu", serving: "gugu", perpTimeHours: "gugu", perpTimeMinutes: "gugu", spicy: "asfa", category: "gugu", difficulty: "gugu", ingredientList: [IngredientModel(id: UUID(), value: "saf", valueType: "asf", name: "asfsaf")], instructionList: [InstructionModel(index: 1, text: "gugugu")]), RecipeModel(id: UUID(), name: "gugu", serving: "gugu", perpTimeHours: "gugu", perpTimeMinutes: "gugu", spicy: "asfa", category: "gugu", difficulty: "gugu", ingredientList: [IngredientModel(id: UUID(), value: "saf", valueType: "asf", name: "asfsaf")], instructionList: [InstructionModel(index: 1, text: "gugugu")])]

    init(repository: DataRepository) {
        self.repository = repository
    }

    func loadRecipes() async {
        let result = await repository.fetchAllRecipes()
        switch result {
        case .success(let result):
            self.recipes = result
            
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
