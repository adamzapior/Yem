//
//  IngridientModel.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import CoreData
import Foundation

struct IngredientModel {
    var id: UUID
    var name: String
    var value: String
    var valueType: IngredientValueTypeModel
}

extension IngredientModel {
    func createEntity(context: NSManagedObjectContext) -> IngredientEntity {
        let entity = IngredientEntity(context: context)
        entity.id = self.id
        entity.name = self.name
        entity.value = self.value
        entity.valueType = self.valueType.name
        return entity
    }
}

struct IngredientValueTypeModel {
    let name: String

    static let unit = IngredientValueTypeModel(name: "Unit")
    static let grams = IngredientValueTypeModel(name: "Grams (g)")
    static let kilograms = IngredientValueTypeModel(name: "Kilograms (kg)")
    static let milliliters = IngredientValueTypeModel(name: "Milliliters (ml)")
    static let liters = IngredientValueTypeModel(name: "Liters (L)")
    static let teaspoons = IngredientValueTypeModel(name: "Teaspoons (tsp)")
    static let tablespoons = IngredientValueTypeModel(name: "Tablespoons (Tbsp)")
    static let cups = IngredientValueTypeModel(name: "Cups (c)")
    static let pinch = IngredientValueTypeModel(name: "Pinch")

    static var allCases: [IngredientValueTypeModel] = [
        unit,
        grams,
        kilograms,
        milliliters,
        liters,
        teaspoons,
        tablespoons,
        cups,
        pinch
    ]
}

extension IngredientValueTypeModel {
    static func from(name: String) -> IngredientValueTypeModel {
        return self.allCases.first { $0.name == name } ?? .unit 
    }
}
