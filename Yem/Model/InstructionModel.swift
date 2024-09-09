//
//  InstructionModel.swift
//  Yem
//
//  Created by Adam Zapiór on 19/01/2024.
//

import Foundation
import CoreData

struct InstructionModel {
    var id: UUID
    var index: Int
    var text: String
    
    func createEntity(context: NSManagedObjectContext) -> InstructionEntity {
        let entity = InstructionEntity(context: context)
        entity.id = self.id
        entity.indexPath = self.index
        entity.text = self.text
        
        return entity
    }
}
