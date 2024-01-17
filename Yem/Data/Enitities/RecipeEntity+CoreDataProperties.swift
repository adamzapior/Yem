//
//  RecipeEntity+CoreDataProperties.swift
//  Yem
//
//  Created by Adam Zapiór on 17/01/2024.
//
//

import Foundation
import CoreData


extension RecipeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecipeEntity> {
        return NSFetchRequest<RecipeEntity>(entityName: "RecipeEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var servings: String
    @NSManaged public var prepTimeHours: String
    @NSManaged public var prepTimeMinutes: String
    @NSManaged public var spicy: String
    @NSManaged public var category: String

}

extension RecipeEntity : Identifiable {

}
