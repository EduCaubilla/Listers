//
//  MockPersistenceManager.swift
//  ListersTests
//
//  Created by Edu Caubilla on 29/7/25.
//

import Foundation
import CoreData
@testable import Listers

class MockPersistenceManager: PersistenceManagerProtocol {
    // Mock data
    var mockProducts: [DMProduct]?
    var mockAllProducts: [DMProduct]?
    var mockLists: [DMList]?
    var mockItems: [DMItem]?
    var mockCategories: [DMCategory]?
    var mockSettings: DMSettings?
    var mockNextProductId: Int = 1
    var mockSelectedList: DMList?
    var mockList: DMList?
    var mockProduct: DMProduct?
    var mockCategory: DMCategory?

    // Control behavior
    var shouldCreateProduct: Bool = true
    var shouldCreateItem: Bool = true
    var shouldCreateList: Bool = true
    var shouldCreateSettings: Bool = true
    var shouldUpdateSettings: Bool = true
    var shouldSavePersistence: Bool = true
    var shouldRemoveObject: Bool = true
    var shouldSetListCompleteness: Bool = false
    var shouldIsDuplicateProduct: Bool = false

    // Tracking calls
    var fetchAllActiveProductsCalled = false
    var fetchAllProductsCalled = false
    var fetchAllListsCalled = false
    var fetchAllCategoriesCalled = false
    var fetchNextProductIdCalled = false
    var createProductCalled = false
    var createItemCalled = false
    var createListCalled = false
    var createSettingsCalled = false
    var updateSettingsCalled = false
    var savePersistenceCalled = false
    var removeCalled = false
    var fetchSelectedListCalled = false
    var fetchListCalled = false
    var fetchItemsForListCalled = false
    var fetchProductByIdCalled = false
    var fetchProductsByCategoryCalled = false
    var fetchProductByCategoryIdCalled = false
    var fetchCategoryByProductIdCalled = false
    var fetchSettingsCalled = false
    var setListCompletenessCalled = false
    var isDuplicateProductCalled = false
    var fetchCalled = false

    // Tracking parameters for products
    var lastCreatedProductId: Int?
    var lastCreatedProductName: String?
    var lastCreatedProductNotes: String?
    var lastCreatedProductCategoryId: Int16?
    var lastCreatedProductActive: Bool?
    var lastCreatedProductFavorite: Bool?
    var lastCreatedProductCustom: Bool?
    var lastCreatedProductSelected: Bool?

    // Tracking parameters for items
    var lastCreatedItemName: String?
    var lastCreatedItemDescription: String?
    var lastCreatedItemQuantity: Int16?
    var lastCreatedItemFavorite: Bool?
    var lastCreatedItemPriority: Priority?
    var lastCreatedItemCompleted: Bool?
    var lastCreatedItemSelected: Bool?
    var lastCreatedItemCreationDate: Date?
    var lastCreatedItemEndDate: Date?
    var lastCreatedItemImage: String?
    var lastCreatedItemLink: String?
    var lastCreatedItemListId: UUID?

    // Tracking parameters for lists
    var lastCreatedListName: String?
    var lastCreatedListDescription: String?
    var lastCreatedListCreationDate: Date?
    var lastCreatedListEndDate: Date?
    var lastCreatedListPinned: Bool?
    var lastCreatedListSelected: Bool?
    var lastCreatedListExpanded: Bool?
    var lastCreatedListCompleted: Bool?

    // Tracking parameters for settings
    var lastCreatedSettingsItemDescription: Bool?
    var lastCreatedSettingsItemQuantity: Bool?
    var lastCreatedSettingsItemEndDate: Bool?
    var lastCreatedSettingsListDescription: Bool?
    var lastCreatedSettingsListEndDate: Bool?

    var lastUpdatedSettingsItemDescription: Bool?
    var lastUpdatedSettingsItemQuantity: Bool?
    var lastUpdatedSettingsItemEndDate: Bool?
    var lastUpdatedSettingsListDescription: Bool?
    var lastUpdatedSettingsListEndDate: Bool?

    // MARK: - Items/Lists
    func createItem(name: String, description: String?, quantity: Int16, favorite: Bool, priority: Listers.Priority, completed: Bool, selected: Bool, creationDate: Date, endDate: Date?, image: String?, link: String?, listId: UUID?) -> Bool {
        createItemCalled = true
        lastCreatedItemName = name
        lastCreatedItemDescription = description
        lastCreatedItemQuantity = quantity
        lastCreatedItemFavorite = favorite
        lastCreatedItemPriority = priority
        lastCreatedItemCompleted = completed
        lastCreatedItemSelected = selected
        lastCreatedItemCreationDate = creationDate
        lastCreatedItemEndDate = endDate
        lastCreatedItemImage = image
        lastCreatedItemLink = link
        lastCreatedItemListId = listId
        return shouldCreateItem
    }

    func fetchItemsForList(withId listId: UUID) -> [DMItem]? {
        fetchItemsForListCalled = true
        return mockItems
    }

    func createList(name: String, description: String, creationDate: Date, endDate: Date?, pinned: Bool, selected: Bool, expanded: Bool, completed: Bool) -> Bool {
        createListCalled = true
        lastCreatedListName = name
        lastCreatedListDescription = description
        lastCreatedListCreationDate = creationDate
        lastCreatedListEndDate = endDate
        lastCreatedListPinned = pinned
        lastCreatedListSelected = selected
        lastCreatedListExpanded = expanded
        lastCreatedListCompleted = completed
        return shouldCreateList
    }

    func fetchList(_ listId: UUID) -> DMList? {
        fetchListCalled = true
        return mockList
    }

    func fetchSelectedList() -> DMList? {
        fetchSelectedListCalled = true
        return mockSelectedList
    }

    func fetchAllLists() -> [DMList]? {
        fetchAllListsCalled = true
        return mockLists
    }

    func setListCompleteness(for listId: UUID) -> Bool {
        setListCompletenessCalled = true
        return shouldSetListCompleteness
    }

    // MARK: - Categories/Products
    func fetchNextProductId() -> Int {
        fetchNextProductIdCalled = true
        return mockNextProductId
    }

    func isDuplicateProduct(productId: Int16) -> Bool {
        isDuplicateProductCalled = true
        return shouldIsDuplicateProduct
    }

    func createProduct(id: Int, name: String, notes: String?, categoryId: Int16, active: Bool, favorite: Bool, custom: Bool, selected: Bool) -> Bool {
        createProductCalled = true
        lastCreatedProductId = id
        lastCreatedProductName = name
        lastCreatedProductNotes = notes
        lastCreatedProductCategoryId = categoryId
        lastCreatedProductActive = active
        lastCreatedProductFavorite = favorite
        lastCreatedProductCustom = custom
        lastCreatedProductSelected = selected
        return shouldCreateProduct
    }

    func fetchAllProducts() -> [DMProduct]? {
        fetchAllProductsCalled = true
        return mockAllProducts
    }

    func fetchAllActiveProducts() -> [DMProduct]? {
        fetchAllActiveProductsCalled = true
        return mockProducts
    }

    func fetchProductById(_ id: Int16) -> DMProduct? {
        fetchProductByIdCalled = true
        return mockProduct
    }

    func fetchProductsByCategory(_ category: DMCategory) -> [DMProduct]? {
        fetchProductsByCategoryCalled = true
        return mockProducts
    }

    func fetchProductByCategoryId(_ categoryId: Int16) -> DMProduct? {
        fetchProductByCategoryIdCalled = true
        return mockProduct
    }

    func fetchAllCategories() -> [DMCategory]? {
        fetchAllCategoriesCalled = true
        return mockCategories
    }

    func fetchCategoryByProductId(_ productId: Int16) -> DMCategory? {
        fetchCategoryByProductIdCalled = true
        return mockCategory
    }

    // MARK: - Settings
    func fetchSettings() -> DMSettings? {
        fetchSettingsCalled = true
        return mockSettings
    }

    func createSettings(itemDescription: Bool, itemQuantity: Bool, itemEndDate: Bool, listDescription: Bool, listEndDate: Bool) -> Bool {
        createSettingsCalled = true
        lastCreatedSettingsItemDescription = itemDescription
        lastCreatedSettingsItemQuantity = itemQuantity
        lastCreatedSettingsItemEndDate = itemEndDate
        lastCreatedSettingsListDescription = listDescription
        lastCreatedSettingsListEndDate = listEndDate
        return shouldCreateSettings
    }

    func updateSettings(itemDescription: Bool, itemQuantity: Bool, itemEndDate: Bool, listDescription: Bool, listEndDate: Bool) -> Bool {
        updateSettingsCalled = true
        lastUpdatedSettingsItemDescription = itemDescription
        lastUpdatedSettingsItemQuantity = itemQuantity
        lastUpdatedSettingsItemEndDate = itemEndDate
        lastUpdatedSettingsListDescription = listDescription
        lastUpdatedSettingsListEndDate = listEndDate
        return shouldUpdateSettings
    }

    // MARK: - Generic
    func fetch<T: NSManagedObject>(type: T.Type, predicate: NSPredicate?) -> [T]? {
        fetchCalled = true
        // Return appropriate mock data based on type
        if type == DMProduct.self {
            return mockProducts as? [T]
        } else if type == DMList.self {
            return mockLists as? [T]
        } else if type == DMItem.self {
            return mockItems as? [T]
        } else if type == DMCategory.self {
            return mockCategories as? [T]
        } else if type == DMSettings.self {
            return mockSettings.map { [$0] } as? [T]
        }
        return nil
    }

    func savePersistence() -> Bool {
        savePersistenceCalled = true
        return shouldSavePersistence
    }

    func remove<T: NSManagedObject>(_ object: T) -> Bool {
        removeCalled = true
        return shouldRemoveObject
    }
}
