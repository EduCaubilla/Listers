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
}
