//
//  ProductExtension.swift
//  Listers
//
//  Created by Edu Caubilla on 8/7/25.
//

import SwiftUI
import CoreData

extension DMProduct : JSONLoadable {

    typealias JSONModel = ProductModel

    static var entityName: String { "DMProduct" }
    static var jsonFileName: String { "productsES" }

    static func mapper(from jsonModel: ProductModel, context: NSManagedObjectContext) -> Self {
        let product = DMProduct(context: context)
        product.uuid = UUID()
        product.id = jsonModel.id
        product.name = jsonModel.name
        product.note = jsonModel.note
        product.categoryId = jsonModel.categoryId
        product.favorite = false
        product.active = true
        product.custom = false

        return product as! Self
    }
}
