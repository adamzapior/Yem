//
//  RecipeEntity+CoreDataProperties.swift
//  Yem
//
//  Created by Adam Zapiór on 18/01/2024.
//
//

import CoreData
import Foundation

@objc(RecipeEntity)
public class RecipeEntity: NSManagedObject {

}


public extension RecipeEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<RecipeEntity> {
        return NSFetchRequest<RecipeEntity>(entityName: "RecipeEntity")
    }

    @NSManaged var category: String
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var prepTimeHours: String
    @NSManaged var prepTimeMinutes: String
    @NSManaged var servings: String
    @NSManaged var spicy: String
    @NSManaged var difficulty: String
    @NSManaged var ingredients: Set<IngredientEntity>
    @NSManaged var instructions: Set<InstructionEntity>
    @NSManaged var isImageSaved: Bool
    @NSManaged var isFavourite: Bool
}

// MARK: Generated accessors for ingredients

public extension RecipeEntity {
    @objc(addIngredientsObject:)
    @NSManaged func addToIngredients(_ value: IngredientEntity)

    @objc(removeIngredientsObject:)
    @NSManaged func removeFromIngredients(_ value: IngredientEntity)

    @objc(addIngredients:)
    @NSManaged func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged func removeFromIngredients(_ values: NSSet)
}

// MARK: Generated accessors for instructions

public extension RecipeEntity {
    @objc(addInstructionsObject:)
    @NSManaged func addToInstructions(_ value: InstructionEntity)

    @objc(removeInstructionsObject:)
    @NSManaged func removeFromInstructions(_ value: InstructionEntity)

    @objc(addInstructions:)
    @NSManaged func addToInstructions(_ values: NSSet)

    @objc(removeInstructions:)
    @NSManaged func removeFromInstructions(_ values: NSSet)
}

extension RecipeEntity: Identifiable {}
