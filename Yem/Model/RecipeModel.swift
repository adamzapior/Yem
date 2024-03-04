//
//  RecipeModel.swift
//  Yem
//
//  Created by Adam Zapiór on 18/01/2024.
//

import Foundation

struct RecipeModel {
    var id: UUID
    var name: String
    var serving: String
    var perpTimeHours: String
    var perpTimeMinutes: String
    var spicy: String
    var category: String
    var difficulty: String
    var ingredientList: [IngredientModel]
    var instructionList: [InstructionModel]
    var isImageSaved: Bool
    var isFavourite: Bool
}


enum RecipeCategory: String {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case desserts = "Desserts"
    case snacks = "Snacks"
    case beverages = "Beverages"
    case appetizers = "Appetizers"
    case sideDishes = "Side Dishes"
    case vegan = "Vegan"
    case vegetarian = "Vegetarian"
}

extension RecipeModel {
    static func mapToModel(entity: RecipeEntity) -> RecipeModel {
        return RecipeModel(id: entity.id,
                           name: entity.name,
                           serving: entity.servings,
                           perpTimeHours: entity.prepTimeHours,
                           perpTimeMinutes: entity.prepTimeMinutes,
                           spicy: entity.spicy,
                           category: entity.category,
                           difficulty: entity.difficulty,
                           ingredientList: entity.ingredients.map { list in
                               IngredientModel(id: list.id,
                                               value: list.value,
                                               valueType: list.valueType,
                                               name: list.name)
                           }, instructionList: entity.instructions.map { step in
                               InstructionModel(id: step.id,
                                                index: step.indexPath,
                                                text: step.text)
                           },
                           isImageSaved: entity.isImageSaved, 
                           isFavourite: entity.isFavourite)
    }
}
