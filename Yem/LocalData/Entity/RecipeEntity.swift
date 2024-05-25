//
//  Recipe+CoreDataClass.swift
//  Yem
//
//  Created by Adam Zapiór on 15/01/2024.
//
//

import Foundation
import CoreData

@objc(Recipe)
final class RecipeEntity: NSManagedObject, Identifiable {

    @NSManaged public var id: Int64
    @NSManaged public var name: String
    @NSManaged public var difficulty: String
    @NSManaged public var servings: Int64
    @NSManaged public var perpTimeHours: Int64
    @NSManaged public var prepTimeMinutes: Int64
    @NSManaged public var spicy: String
    @NSManaged public var category: String
    @NSManaged public var ingredientList: NSSet

}

extension RecipeEntity {
    private static var recipeFetchRequest: NSFetchRequest<RecipeEntity> {
        NSFetchRequest(entityName: "Recipe")
    }
}

