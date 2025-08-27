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

    //MARK: - ITEMS
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
    ) -> Bool
    func fetchItemsForList(withId listId: UUID) -> [DMItem]?

    //MARK: - LISTS
    func createList(
        name: String,
        description: String,
        creationDate: Date,
        endDate: Date?,
        pinned: Bool,
        selected: Bool,
        expanded: Bool,
        completed: Bool
    ) -> Bool
    func fetchList(_ listId : UUID) -> DMList?
    func fetchSelectedList() -> DMList?
    func fetchAllLists() -> [DMList]?
    func setListCompleteness(for listId: UUID) -> Bool

    //MARK: - PRODUCTS
    func fetchNextProductId() -> Int
    func createProduct(
        id: Int,
        name: String,
        notes: String?,
        categoryId: Int16,
        active: Bool,
        favorite: Bool,
        custom: Bool,
        selected: Bool
    ) -> Bool
    func fetchAllProducts() -> [DMProduct]?
    func fetchAllActiveProducts() -> [DMProduct]?
    func fetchProductsByCategory(_ category: DMCategory) -> [DMProduct]?
    func fetchProductByCategoryId(_ categoryId: Int16) -> DMProduct?

    //MARK: - CATEGORIES
    func fetchAllCategories() -> [DMCategory]?
    func fetchCategoryByProductId(_ productId: Int16) -> DMCategory?

    //MARK: - SETTINGS
    func fetchSettings() -> DMSettings?
    func createSettings(
        itemDescription: Bool,
        itemQuantity: Bool,
        itemEndDate: Bool,
        listDescription: Bool,
        listEndDate: Bool
    ) -> Bool
    func updateSettings(
        itemDescription: Bool,
        itemQuantity: Bool,
        itemEndDate: Bool,
        listDescription: Bool,
        listEndDate: Bool
    ) -> Bool

    //MARK: - COMMON
    func fetch<T : NSManagedObject>(type: T.Type, predicate: NSPredicate?) -> [T]?
    func savePersistence() -> Bool
    func remove<T: NSManagedObject>(_ object: T) -> Bool
}
