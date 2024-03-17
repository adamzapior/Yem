//
//  InstructionEntity+CoreDataProperties.swift
//  Yem
//
//  Created by Adam Zapiór on 19/01/2024.
//
//

import Foundation
import CoreData

@objc(InstructionEntity)
public class InstructionEntity: NSManagedObject {


    @nonobjc public class func fetchRequest() -> NSFetchRequest<InstructionEntity> {
        return NSFetchRequest<InstructionEntity>(entityName: "InstructionEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var indexPath: Int
    @NSManaged public var text: String
    @NSManaged public var origin: RecipeEntity

}
