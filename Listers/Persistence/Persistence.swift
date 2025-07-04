//
//  Persistence.swift
//  Listers
//
//  Created by Edu Caubilla on 12/6/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Listers")

//        deleteAllData()

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                NSLog("Unresolved error \(error), \(error.userInfo)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true

    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print("Error trying to save context: \(error), \(error.userInfo)")
                NSLog("Error trying to save context: \(error), \(error.userInfo)")
            }

            print("Context Saved successfully!")
        }
    }

    func deleteAllData() {
//        let entityNames = ["DMProduct", "DMCategory", "DMItem", "DMList"]
        let entityNames = ["DMItem", "DMList"]

        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(deleteRequest)
            } catch {
                print("Error deleting \(entityName): \(error)")
            }
        }

        do {
            try context.save()
        } catch {
            print("Error saving: \(error)")
        }
        print("All data deleted successfully!")
    }

    //MARK: - PREVIEW CONTENT
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        for _ in 0..<15 {
            let itemNumber = Int.random(in: 0..<100)

            let newItem = DMItem(context: viewContext)

            newItem.id = UUID()
            newItem.name = "Item \(itemNumber)"
            newItem.note = "This is item \(itemNumber)."
            newItem.quantity = Int16.random(in: 1...10)
            newItem.creationDate = Date()
            newItem.favorite = Bool.random()
            newItem.completed = Bool.random()
            newItem.listId = UUID()
        }

        do {
            try viewContext.save()
        } catch let error as NSError {
            print("Error trying to save preview item data: \(error), \(error.userInfo)")
            NSLog("Error trying to save preview item data: \(error), \(error.userInfo)")
        }
        return result
    }()

    @MainActor
    static let previewList: PersistenceController = {
        let resultList = PersistenceController(inMemory: true)
        let viewContextList = resultList.container.viewContext

        for _ in 0..<5 {
            let listNumber = Int.random(in: 0..<5)
            let listId = UUID()

            let newList = DMList(context: viewContextList)
            newList.id = listId
            newList.name = "Preview List \(listNumber)"
            newList.creationDate = Date.now
            newList.pinned = false
            newList.notes = "This is a preview list \(listNumber)."
            newList.items = []

            for _ in 0..<3 {
                let itemNumber = Int.random(in: 0..<10)

                let newItem = DMItem(context: viewContextList)

                newItem.id = UUID()
                newItem.name = "Item \(itemNumber)"
                newItem.note = "This is item \(itemNumber)."
                newItem.quantity = Int16.random(in: 1...10)
                newItem.creationDate = Date.now
                newItem.favorite = Bool.random()
                newItem.completed = Bool.random()
                newItem.listId = listId
                newItem.list = newList
            }
        }

        do {
            try viewContextList.save()
        } catch let error as NSError {
            print("Error trying to save preview list data: \(error), \(error.userInfo)")
            NSLog("Error trying to save preview list data: \(error), \(error.userInfo)")
        }

        return resultList
    }()
}
