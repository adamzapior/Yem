//
//  RecipeModel.swift
//  Yem
//
//  Created by Adam Zapiór on 18/01/2024.
//

import CoreData
import Foundation

struct RecipeModel {
    var id: UUID
    var name: String
    var serving: String
    var perpTimeHours: String
    var perpTimeMinutes: String
    var spicy: RecipeSpicy
    var category: RecipeCategory
    var difficulty: RecipeDifficulty
    var ingredientList: [IngredientModel]
    var instructionList: [InstructionModel]
    var isImageSaved: Bool
    var isFavourite: Bool

    func createEntity(context: NSManagedObjectContext) -> RecipeEntity {
        let entity = RecipeEntity(context: context)
        entity.id = self.id
        entity.name = self.name
        entity.servings = self.serving
        entity.prepTimeHours = self.perpTimeHours
        entity.prepTimeMinutes = self.perpTimeMinutes
        entity.spicy = self.spicy.rawValue
        entity.category = self.category.rawValue
        entity.difficulty = self.difficulty.rawValue
        entity.isImageSaved = self.isImageSaved
        entity.isFavourite = self.isFavourite

        // Tworzenie encji dla list składników i instrukcji
        let ingredientEntities = self.ingredientList.map { $0.createEntity(context: context) }
        let instructionEntities = self.instructionList.map { $0.createEntity(context: context) }

        entity.ingredients = Set(ingredientEntities)
        entity.instructions = Set(instructionEntities)

        return entity
    }
}

enum RecipeSpicy: String, CaseIterable {
    case mild = "Mild"
    case medium = "Medium"
    case hot = "Hot"
    case veryHot = "Very hot"

    var displayName: String {
        return rawValue
    }
}

enum RecipeCategory: String, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case vegan = "Vegan"
    case vegetarian = "Vegetarian"
    case desserts = "Desserts"
    case snacks = "Snacks"
    case beverages = "Beverages"
    case appetizers = "Appetizers"
    case sideDishes = "Side Dishes"
    case notSelected = "Not selected"

    var displayName: String {
        return rawValue
    }
}

enum RecipeDifficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hot = "Hard"

    var displayName: String {
        return rawValue
    }
}

extension RecipeModel {
    static var servingRowArray: [Int] {
        return Array(1...36)
    }

    static var timeHoursArray: [Int] {
        return Array(0...48)
    }

    static var timeMinutesArray: [Int] {
        return Array(0...59)
    }
}

extension RecipeModel {
    mutating func sortInstructionsByIndex() {
        self.instructionList.sort { $0.index < $1.index }
    }
}

extension RecipeModel {
    func getPerpTimeString() -> String {
        var perpTimeString = ""
        var hours = ""
        var minutes = ""

        if self.perpTimeHours != "0", self.perpTimeHours != "1", self.perpTimeHours != "" {
            hours = "\(self.perpTimeHours) hours"
        } else if self.perpTimeHours == "1" {
            hours = "\(self.perpTimeHours) hour"
        }

        if self.perpTimeMinutes != "0", self.perpTimeMinutes != "" {
            minutes = "\(self.perpTimeMinutes) min"
        }

        perpTimeString = "\(hours) \(minutes)".trimmingCharacters(in: .whitespaces)
        return perpTimeString
    }

    func getStringForURL() -> String {
        return self.id.uuidString
    }
}
