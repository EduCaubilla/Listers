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
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    //MARK: - PREVIEW CONTENT
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        for _ in 0..<10 {
            let itemNumber = Int.random(in: 0..<100)

            let newItem = DMItem(context: viewContext)
            newItem.id = UUID()
            newItem.name = "Item \(itemNumber)"
            newItem.note = "This is item \(itemNumber)."
            newItem.timestamp = Date()
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error trying to save preview data: \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
