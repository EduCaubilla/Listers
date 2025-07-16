//
//  CategoryExtension.swift
//  Listers
//
//  Created by Edu Caubilla on 8/7/25.
//

import SwiftUI
import CoreData

extension DMCategory: JSONLoadable {
    
    typealias JSONModel = CategoryModel

    static var entityName: String { "DMCategory" }
    static var jsonFileName: String { "categoriesES" }

    static func mapper(from jsonModel: CategoryModel, context: NSManagedObjectContext) -> Self {
        let category = DMCategory(context: context)
        category.uuid = UUID()
        category.name = jsonModel.name
        category.id = jsonModel.id
        category.expanded = jsonModel.expanded

        return category as! Self
    }
}
