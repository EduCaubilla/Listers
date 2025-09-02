//
//  DMCategoryExtension.swift
//  Listers
//
//  Created by Edu Caubilla on 8/7/25.
//

import SwiftUI
import CoreData

extension DMCategory: JSONLoadable {

    static var entityName: String { "DMCategory" }
    
    static var jsonFileName: String {
        let languageCode = L10n.shared.getSystemLanguage()
        return "categories_\(languageCode)"
    }

    static func mapper(from jsonModel: CategoryDTO, context: NSManagedObjectContext) -> Self {
        let category = DMCategory(context: context)
        category.uuid = UUID()
        category.name = jsonModel.name
        category.id = jsonModel.id
        category.expanded = jsonModel.expanded

        return category as! Self
    }
}
