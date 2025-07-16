//
//  PersistenceManager.swift
//  Listers
//
//  Created by Edu Caubilla on 1/7/25.
//

import SwiftUI
import CoreData
import Foundation

protocol PersistenceManagerProtocol {

    func createItem(
        name: String,
        description: String?,
        quantity: Int16,
        favorite: Bool,
        priority: Priority,
        completed: Bool,
        selected: Bool,
        creationDate: Date,
        endDate: Date?,
        image: String?,
        link: String?,
        listId: UUID?
    )

    func createList(
        name: String,
        description: String,
        creationDate: Date,
        endDate: Date?,
        pinned: Bool,
        selected: Bool,
        expanded: Bool,
        completed: Bool
    )
    func fetchList(_ listId : UUID) -> DMList?
    func fetchSelectedList() -> DMList?
    func fetchAllLists() -> [DMList]?
    func fetchItemsForList(withId listId: UUID) -> [DMItem]?
    func setListCompleteness(for listId: UUID)

    func fetch<T : NSManagedObject>(type: T.Type, predicate: NSPredicate?) -> [T]?
    func savePersistence()
    func remove<T: NSManagedObject>(_ object: T)

    func fetchLastProductId() -> Int
    func createProduct(
        id: Int,
        name: String,
        note: String?,
        categoryId: Int16,
        active: Bool,
        favorite: Bool,
        custom: Bool,
        selected: Bool
    )
    func fetchAllProducts() -> [DMProduct]?
    func fetchProductsByCategory(_ category: DMCategory) -> [DMProduct]?
    func fetchProductByCategoryId(_ categoryId: Int16) -> DMProduct?

    func fetchAllCategories() -> [DMCategory]?
    func fetchCategoryByProductId(_ productId: Int16) -> DMCategory?
}
