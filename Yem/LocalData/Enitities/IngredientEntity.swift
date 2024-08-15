//
//  IngredientEntity+CoreDataProperties.swift
//  Yem
//
//  Created by Adam Zapiór on 18/01/2024.
//
//

import CoreData
import Foundation

@objc(IngredientEntity)
public class IngredientEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<IngredientEntity> {
        return NSFetchRequest<IngredientEntity>(entityName: "IngredientEntity")
    }

    @NSManaged public var name: String
    @NSManaged public var value: String
    @NSManaged public var valueType: String
    @NSManaged public var id: UUID
    @NSManaged public var recipe: RecipeEntity
}

extension IngredientEntity: Identifiable {}
