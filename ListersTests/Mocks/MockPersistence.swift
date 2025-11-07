import Foundation
import CoreData

class MockPersistence {
    func makeInMemoryPersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "Listers")

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("In-memory store setup failed '\(error)'")
            }
        }

        return container
    }
}

class MockManagedObject: NSManagedObject {

}
