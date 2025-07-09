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

    //MARK: - FUNCTIONS

    //MARK: - ITEMS/LISTS
    func createItem(name: String, description: String?, quantity: Int16, favorite: Bool, priority: Priority, completed: Bool, selected: Bool, creationDate: Date, endDate: Date?, image: String?, link: String?, listId: UUID?) {
        print("PersistenceManager: Create item \(name)")

        let newItem = DMItem(context: viewContext)
        newItem.id = UUID()
        newItem.name = name
        newItem.note = description
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

        savePersistence()
    }
    
    func createList(name: String, description: String, creationDate: Date, endDate: Date?, pinned: Bool, selected: Bool, expanded: Bool) {
        print("PersistenceManager: Create list \(name)")

        let newList = DMList(context: viewContext)
        newList.id = UUID()
        newList.name = name
        newList.notes = description
        newList.creationDate = creationDate
        newList.pinned = pinned
        newList.selected = selected
        newList.expanded = expanded

        savePersistence()
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

    func savePersistence() {
        do {
            try viewContext.save()
        } catch {
            print("Error trying to save in PersistenceManager: \(error.localizedDescription)")
        }
    }
    
    func remove<T: NSManagedObject>(_ object: T) {
        viewContext.delete(object)
        savePersistence()
    }

    //MARK: - CATEGORIES/PRODUCTS
    func fetchLastProductId() -> Int {
        let allProducts = fetchAllProducts()
        if let allProducts = allProducts {
            let lastProduct = allProducts.last
            if let lastProduct = lastProduct {
                return Int(lastProduct.id)
            }
        } else {
            print("No products found.")
        }

        return 1000
    }

    func createProduct(id: Int, name: String, note: String?, categoryId: Int16, active: Bool, favorite: Bool, custom: Bool = true) {
        let newProduct = DMProduct(context: viewContext)
        newProduct.uuid = UUID()
        newProduct.id = Int16(id)
        newProduct.name = name
        newProduct.note = note
        newProduct.categoryId = categoryId
        newProduct.active = active
        newProduct.favorite = favorite
        newProduct.custom = custom

        savePersistence()
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

    func fetchAllProducts() -> [DMProduct]? {
        let productsFetch : NSFetchRequest<DMProduct> = DMProduct.fetchRequest()
        productsFetch.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        do {
            return try viewContext.fetch(productsFetch)
        }
        catch {
            print("Error fetching lists in PersistenceManager: \(error.localizedDescription)")
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
}
