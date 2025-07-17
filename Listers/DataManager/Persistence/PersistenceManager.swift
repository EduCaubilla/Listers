//
//  PersistenceManager.swift
//  Listers
//
//  Created by Edu Caubilla on 1/7/25.
//

import SwiftUI
import CoreData
import Foundation

struct PersistenceManager : PersistenceManagerProtocol {
    //MARK: - PROPERTIES
    let viewContext: NSManagedObjectContext

    static let shared = PersistenceManager()

    typealias T = NSManagedObject

    //MARK: - INITIALIZER
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
    }

    //MARK: - ITEMS/LISTS
    func createItem(name: String, description: String?, quantity: Double, favorite: Bool, priority: Priority, completed: Bool, selected: Bool, creationDate: Date, endDate: Date?, image: String?, link: String?, listId: UUID?) -> Bool {
        print("PersistenceManager: Create item \(name)")

        let newItem = DMItem(context: viewContext)
        newItem.id = UUID()
        newItem.name = name
        newItem.notes = description
        newItem.quantity = quantity
        newItem.favorite = favorite
        newItem.priority = priority.rawValue
        newItem.completed = completed
        newItem.creationDate = creationDate
        newItem.endDate = endDate ?? Date.now
        newItem.image = image ?? ""
        newItem.link = link ?? ""
        newItem.list = listId != nil ? fetchSelectedList(): nil
        newItem.listId = listId

        return savePersistence()
    }

    func fetchItemsForList(withId listId: UUID) -> [DMItem]? {
        let fetchRequest: NSFetchRequest<DMItem> = DMItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "listId", listId as CVarArg)

        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("There was an error fetching items for selected list: \(error.localizedDescription)")
        }

        return nil
    }


    func createList(name: String, description: String, creationDate: Date, endDate: Date?, pinned: Bool, selected: Bool, expanded: Bool, completed: Bool) -> Bool {
        print("PersistenceManager: Create list \(name)")

        let newList = DMList(context: viewContext)
        newList.id = UUID()
        newList.name = name
        newList.notes = description
        newList.creationDate = creationDate
        newList.pinned = pinned
        newList.selected = selected
        newList.expanded = expanded
        newList.completed = completed

        return savePersistence()
    }

    func fetchList(_ listId : UUID) -> DMList? {
        let resultList = fetch(type: DMList.self, predicate: NSPredicate(format: "%K == %@", "id", listId as CVarArg))!
        if let result = resultList.first {
            return result
        }
        return nil
    }

    func fetchSelectedList() -> DMList? {
        let lists = fetchAllLists()
        return lists?.first(where: { $0.selected })
    }

    func fetchAllLists() -> [DMList]? {
        let listsFetch : NSFetchRequest<DMList> = DMList.fetchRequest()
        do {
            return try viewContext.fetch(listsFetch)
        }
        catch {
            print("Error fetching lists in PersistenceManager: \(error.localizedDescription)")
        }

        return nil
    }


    func setListCompleteness(for listId: UUID) {
        let itemsForList = fetchItemsForList(withId: listId)
        guard let items = itemsForList else {
            print("Error fetching items for selected list in PersistenceManager.")
            return
        }
        
        let isListComplete = items.allSatisfy { $0.completed }

        if let listToUpdate = fetchList(listId) {
            listToUpdate.completed = isListComplete
            print("Set list completed : \(listToUpdate.name!) -> \(isListComplete)")
        }

    }

    //MARK: - CATEGORIES/PRODUCTS
    func fetchLastProductId() -> Int {
        let allProducts = fetchAllProducts()
        if let allProducts = allProducts {
            let sortedProducts = allProducts.sorted { $0.id < $1.id }
            let lastProduct = sortedProducts.last
            if let lastProduct = lastProduct {
                print("Last product id: \(lastProduct.id)")

                let productDuplicated = fetchProductById(lastProduct.id)
                if productDuplicated != nil {
                    return 1000
                }

                return Int(lastProduct.id)
            }
        } else {
            print("No products found.")
        }

        return 1000
    }

    func createProduct(id: Int, name: String, notes: String?, categoryId: Int16, active: Bool, favorite: Bool, custom: Bool = true, selected: Bool = false) -> Bool {
        let newProduct = DMProduct(context: viewContext)
        newProduct.uuid = UUID()
        newProduct.id = Int16(id)
        newProduct.name = name
        newProduct.notes = notes
        newProduct.categoryId = categoryId
        newProduct.active = active
        newProduct.favorite = favorite
        newProduct.custom = custom
        newProduct.selected = selected

        return savePersistence()
    }

    func fetchAllProducts() -> [DMProduct]? {
        let productsFetch : NSFetchRequest<DMProduct> = DMProduct.fetchRequest()
        productsFetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        productsFetch.predicate = NSPredicate(format: "active == true")
        do {
            return try viewContext.fetch(productsFetch)
        }
        catch {
            print("Error fetching lists in PersistenceManager: \(error.localizedDescription)")
        }

        return nil
    }

    func fetchProductById(_ id: Int16) -> DMProduct? {
        let fetchRequest: NSFetchRequest<DMProduct> = DMProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)

        do {
            let fetchResult = try viewContext.fetch(fetchRequest)
            if !fetchResult.isEmpty {
                return fetchResult.first
            }
        } catch {
            print("Error fetching product by id in PersistenceManager: \(error.localizedDescription)")
        }
        return nil
    }

    func fetchProductsByCategory(_ category: DMCategory) -> [DMProduct]? {
        let fetchRequest: NSFetchRequest<DMProduct> = DMProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "categoryId == %d", category.id)

        do {
            let fetchResult = try viewContext.fetch(fetchRequest)
            if !fetchResult.isEmpty {
                return fetchResult
            }
        } catch {
            print("There was an error fetching products by category: \(error.localizedDescription)")
        }

        return nil
    }

    func fetchProductByCategoryId(_ categoryId: Int16) -> DMProduct? {
        let fetchRequest: NSFetchRequest<DMProduct> = DMProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", categoryId)

        do {
            let fetchResult = try viewContext.fetch(fetchRequest)
            if !fetchResult.isEmpty,
               let fetchResultProduct = fetchResult.first {
                return fetchResultProduct
            }
        } catch {
            print("There was an error fetching products by category: \(error.localizedDescription)")
        }

        return nil
    }

    func fetchAllCategories() -> [DMCategory]? {
        let categoriesFetch : NSFetchRequest<DMCategory> = DMCategory.fetchRequest()
        categoriesFetch.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        do {
            return try viewContext.fetch(categoriesFetch)
        }
        catch {
            print("Error fetching lists in PersistenceManager: \(error.localizedDescription)")
        }

        return nil
    }

    func fetchCategoryByProductId(_ productId: Int16) -> DMCategory? {
        if let categoryFetched = fetchProductById(productId) {
            let fetchRequest: NSFetchRequest<DMCategory> = DMCategory.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", categoryFetched.categoryId)

            do {
                let fetchResult = try viewContext.fetch(fetchRequest)
                if !fetchResult.isEmpty,
                   let fetchResultCategory = fetchResult.first {
                    return fetchResultCategory
                }
            } catch {
                print("Error fetching category by productId in PersistenceManager: \(error.localizedDescription)")
            }
        }

        return nil
    }

    //MARK: - SETTINGS
    func fetchSettings() -> DMSettings? {
        return fetch(type: DMSettings.self, predicate: nil)?.first
    }

    func createSettings(itemDescription: Bool, itemQuantity: Bool, itemEndDate: Bool, listDescription: Bool, listEndDate: Bool) -> Bool {
        let newSettings = DMSettings(context: viewContext)
        newSettings.itemEndDate = itemEndDate
        newSettings.itemDescription = itemDescription
        newSettings.itemQuantity = itemQuantity
        newSettings.listEndDate = listEndDate
        newSettings.listDescription = listDescription

        return savePersistence()
    }

    func updateSettings(itemDescription: Bool, itemQuantity: Bool, itemEndDate: Bool, listDescription: Bool, listEndDate: Bool) -> Bool {
        let updatedSettings = DMSettings(context: viewContext)
        updatedSettings.itemDescription = itemDescription
        updatedSettings.itemQuantity = itemQuantity
        updatedSettings.itemEndDate = itemEndDate
        updatedSettings.listDescription = listDescription
        updatedSettings.listEndDate = listEndDate

        if let settingsToUpdate = fetchSettings() {
            settingsToUpdate.itemDescription = updatedSettings.itemDescription
            settingsToUpdate.itemQuantity = updatedSettings.itemQuantity
            settingsToUpdate.itemEndDate = updatedSettings.itemEndDate
            settingsToUpdate.listDescription = updatedSettings.listDescription
            settingsToUpdate.listEndDate = updatedSettings.listEndDate
        }

        return savePersistence()
    }

    //MARK: - GENERIC
    func fetch<T: NSManagedObject>(type: T.Type, predicate: NSPredicate?) -> [T]? {
        let fetchRequest = T.fetchRequest()
        fetchRequest.predicate = predicate

        guard let typedRequest = fetchRequest as? NSFetchRequest<T> else {
            print("Failed to cast fetch request to NSFetchRequest<T>")
            return nil
        }

        do {
            return try viewContext.fetch(typedRequest)
        } catch {
            print("There was an error fetching items for selected list: \(error.localizedDescription)")
        }

        return nil
    }

    func savePersistence() -> Bool {
        do {
            try viewContext.save()
        } catch {
            print("Error trying to save in PersistenceManager: \(error.localizedDescription)")
            return false
        }
        return true
    }

    func remove<T: NSManagedObject>(_ object: T) -> Bool {
        viewContext.delete(object)
        return savePersistence()
    }
}
