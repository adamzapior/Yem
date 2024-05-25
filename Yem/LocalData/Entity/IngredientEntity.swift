//
//  Ingredient+CoreDataClass.swift
//  Yem
//
//  Created by Adam Zapiór on 15/01/2024.
//
//

import Foundation
import CoreData

@objc(Ingredient)
final class IngredientEntity: NSManagedObject, Identifiable {

    @NSManaged public var id: Int64
    @NSManaged public var value: String
    @NSManaged public var valueType: String
    @NSManaged public var name: String
    
}

extension IngredientEntity {
    private static var ingredientFetchRequest: NSFetchRequest<IngredientEntity> {
        NSFetchRequest(entityName: "Ingredient")
    }
}
