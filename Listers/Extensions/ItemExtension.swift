//
//  ItemExtension.swift
//  Listers
//
//  Created by Edu Caubilla on 28/8/25.
//

import Foundation
import CoreData

extension DMItem : JSONLoadable {
    typealias JSONModel = ItemModel

    static var entityName: String {
        String(describing: self)
    }

    static var jsonFileName: String { "" }

    static func mapper(from jsonModel: ItemModel, context: NSManagedObjectContext) -> Self {
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

    func toModel() -> ItemModel {
        ItemModel(
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
