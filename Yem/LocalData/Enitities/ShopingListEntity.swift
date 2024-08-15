//
//  ShopingListEntity+CoreDataProperties.swift
//  Yem
//
//  Created by Adam Zapiór on 13/03/2024.
//
//

import CoreData
import Foundation

@objc(ShopingListEntity)
public class ShopingListEntity: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShopingListEntity> {
        return NSFetchRequest<ShopingListEntity>(entityName: "ShopingListEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var isChecked: Bool
    @NSManaged public var name: String
    @NSManaged public var value: String
    @NSManaged public var valueType: String
}
