//
//  DMItemExtension.swift
//  Listers
//
//  Created by Edu Caubilla on 28/8/25.
//

import Foundation
import CoreData

extension DMItem {
    static func mapper(from jsonModel: ItemDTO, context: NSManagedObjectContext) -> Self {
        let item = Self(context: context)
        item.id = jsonModel.id
        item.listId = jsonModel.listId
        item.name = jsonModel.name
        item.notes = jsonModel.notes
        item.priority = jsonModel.priority
        item.quantity = Int16(jsonModel.quantity ?? 0)
        item.creationDate = jsonModel.creationDate
        item.endDate = jsonModel.endDate

        return item
    }

    func toModel() -> ItemDTO {
        ItemDTO(
            id: id ?? UUID(),
            listId: listId ?? UUID(),
            name: name ?? "",
            notes: notes ?? "",
            priority: priority ?? "Normal",
            quantity: Int(quantity),
            creationDate: creationDate ?? Date(),
            endDate: endDate ?? Date()
            )
    }
}
