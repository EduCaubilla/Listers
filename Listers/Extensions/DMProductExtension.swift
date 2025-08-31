//
//  DMProductExtension.swift
//  Listers
//
//  Created by Edu Caubilla on 8/7/25.
//

import SwiftUI
import CoreData

extension DMProduct : JSONLoadable {
    static var entityName: String { "DMProduct" }

    static var jsonFileName: String {
        let languageCode = L10n.shared.getSystemLanguage()
        return "products_\(languageCode)"
    }

    static func mapper(from jsonModel: ProductDTO, context: NSManagedObjectContext) -> Self {
        let product = DMProduct(context: context)
        product.uuid = UUID()
        product.id = jsonModel.id
        product.name = jsonModel.name
        product.notes = jsonModel.notes
        product.categoryId = jsonModel.categoryId
        product.favorite = false
        product.active = true
        product.custom = false

        return product as! Self
    }
}
