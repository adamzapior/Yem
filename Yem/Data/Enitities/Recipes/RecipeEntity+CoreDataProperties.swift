//
//  RecipeEntity+CoreDataProperties.swift
//  Yem
//
//  Created by Adam Zapiór on 18/01/2024.
//
//

import Foundation
import CoreData


extension RecipeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecipeEntity> {
        return NSFetchRequest<RecipeEntity>(entityName: "RecipeEntity")
    }

    @NSManaged public var category: String
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var prepTimeHours: String
    @NSManaged public var prepTimeMinutes: String
    @NSManaged public var servings: String
    @NSManaged public var spicy: String
    @NSManaged public var difficulty: String
    @NSManaged public var ingredients: Set<IngredientEntity>
    @NSManaged public var instructions: Set<InstructionEntity>


}

// MARK: Generated accessors for ingredients
extension RecipeEntity {

    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: IngredientEntity)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: IngredientEntity)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)

}

// MARK: Generated accessors for instructions
extension RecipeEntity {

    @objc(addInstructionsObject:)
    @NSManaged public func addToInstructions(_ value: InstructionEntity)

    @objc(removeInstructionsObject:)
    @NSManaged public func removeFromInstructions(_ value: InstructionEntity)

    @objc(addInstructions:)
    @NSManaged public func addToInstructions(_ values: NSSet)

    @objc(removeInstructions:)
    @NSManaged public func removeFromInstructions(_ values: NSSet)

}

extension RecipeEntity : Identifiable {

}
