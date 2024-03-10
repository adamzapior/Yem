//
//  ShopingListEntity+CoreDataProperties.swift
//  Yem
//
//  Created by Adam Zapiór on 19/01/2024.
//
//

import Foundation
import CoreData


extension ShopingListEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShopingListEntity> {
        return NSFetchRequest<ShopingListEntity>(entityName: "ShopingListEntity")
    }

    @NSManaged public var ingredient: Set<IngredientEntity>?

}

// MARK: Generated accessors for list
extension ShopingListEntity {

    @objc(addListObject:)
    @NSManaged public func addToList(_ value: IngredientEntity)

    @objc(removeListObject:)
    @NSManaged public func removeFromList(_ value: IngredientEntity)

    @objc(addList:)
    @NSManaged public func addToList(_ values: NSSet)

    @objc(removeList:)
    @NSManaged public func removeFromList(_ values: NSSet)

}

extension ShopingListEntity : Identifiable {

}
