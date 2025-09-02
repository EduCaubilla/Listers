//
//  DMListExtension.swift
//  Listers
//
//  Created by Edu Caubilla on 28/8/25.
//

import SwiftUI
import CoreData

extension DMList {
    static func mapper(from jsonModel: ListDTO, context: NSManagedObjectContext) -> Self {
        let list = Self(context: context)
        list.id = jsonModel.id
        list.name = jsonModel.name
        list.notes = jsonModel.notes
        list.creationDate = jsonModel.creationDate
        list.endDate = jsonModel.endDate
        list.selected = true
        list.completed = false
        list.pinned = false
        list.expanded = false

        let items = jsonModel.items.map { itemModel -> DMItem in
            let item = DMItem(context: context)
            item.id = itemModel.id
            item.listId = itemModel.listId
            item.name = itemModel.name
            item.notes = itemModel.notes
            item.priority = itemModel.priority
            item.quantity = Int16(itemModel.quantity ?? 0)
            item.creationDate = itemModel.creationDate
            item.endDate = itemModel.endDate
            return item
        }
        list.items = NSSet(array: items)

        return list
    }

    func toModel() -> ListDTO {
        ListDTO(
            id: self.id ?? UUID(),
            name: self.name ?? "",
            items: (self.items as? Set<DMItem> ?? []).map { $0.toModel() },
            notes: notes ?? "",
            creationDate: self.creationDate ?? Date(),
            endDate: self.endDate ?? Date(),
            selected: true
        )
    }
}
