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

        //Enable lightweight migration
        let description = container.persistentStoreDescriptions.first
        print("Core Data SQLite file is located at: \(description?.url?.path ?? "Unknown")")

        if inMemory {
            description?.url = URL(fileURLWithPath: "/dev/null")
//        } else {
//            #if DEBUG
//            if let storeURL = description?.url {
//                do {
//                    try FileManager.default.removeItem(at: storeURL)
//                    print("Store data wiped: \(storeURL)")
//                } catch {
//                    print("Couldn't remove store data: \(error)")
//                }
//            }
//            #endif
        }

        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true

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

//    private func loadDataFromJSON() {
//        guard let url = Bundle.main.url(forResource: "ListersCategoriesES", withExtension: "json"),
//              let data = try? Data(contentsOf: url) else {
//            print("Error: the json file was not found")
//            return
//        }
//
//        do {
//            let decoder = JSONDecoder()
//            let jsonData = try decoder.decode([DMCategory].self, from: data)
//
//            let context = container.viewContext
//
//            // Crear entidades de Core Data desde JSON
//            for item in jsonData {
//                let entity = TuEntidad(context: context)
//                entity.nombre = item.nombre
//                entity.id = item.id
//                // Mapear otros campos...
//            }
//
//            try context.save()
//            print("Datos cargados exitosamente desde JSON")
//
//        } catch {
//            print("Error cargando datos desde JSON: \(error)")
//        }
//    }

    //MARK: - PREVIEW CONTENT

    #if DEBUG
    @MainActor
    static let previewCategoriesProducts: PersistenceController = {
        let catResults = PersistenceController(inMemory: true)
        let catViewContext = catResults.container.viewContext

        let categoryArray = [ "Alimentación", "Bebidas", "Frutas y verduras", "Hogar y cocina", "Bricolaje y herramientas", "Oficina y papelería", "Ropa y calzado", "Deporte y aire libre", "Salud y belleza", "Otros" ]

        for i in 1..<10 {
            let newCategory = DMCategory(context: catViewContext)
            newCategory.uuid = UUID()
            newCategory.id = Int16(i)
            newCategory.name = "Category \(i)"
            newCategory.expanded = i % 2 == 0 ? true : false
        }

        let productArray = ["Arroz", "Lentejas", "Atún",
                            "Agua", "Zumo", "Leche",
                            "Tomate", "Lechuga", "Pimiento",
                            "Detergente", "Lavavajillas", "Papel higiénico",
                            "Clavos", "Tornillos", "Tacos",
                            "Lápiz", "Boli", "Folios",
                            "Camiseta", "Sudadera", "Chanclas",
                            "Balón", "Esterilla", "Pesas",
                            "Gel de baño", "Crema solar", "Champú",
                            "Otro"]

        for i in 0..<productArray.count {
            let newProduct = DMProduct(context: catViewContext)
            newProduct.uuid = UUID()
            newProduct.id = Int16(i)
            newProduct.name = productArray[i]
            newProduct.note = ""
            newProduct.active = true
            newProduct.favorite = false

            switch i {
                case 0..<3:
                    newProduct.categoryId = 1
                case 3..<6:
                    newProduct.categoryId = 2
                case 6..<9:
                    newProduct.categoryId = 3
                case 9..<12:
                    newProduct.categoryId = 4
                case 12..<15:
                    newProduct.categoryId = 5
                case 15..<18:
                    newProduct.categoryId = 6
                case 19..<22:
                    newProduct.categoryId = 7
                case 22..<25:
                    newProduct.categoryId = 8
                case 25..<28:
                    newProduct.categoryId = 9
                case 29:
                    newProduct.categoryId = 10
                    break
                default:
                    newProduct.categoryId = 10
                    break
            }
    }

        do {
            try catViewContext.save()
            print("Saved Preview categories & products.")
        } catch let error as NSError {
            print("Error trying to save preview categories data: \(error), \(error.userInfo)")
            NSLog("Error trying to save preview categories data: \(error), \(error.userInfo)")
        }
        return catResults
    }()

    @MainActor
    static let previewListItems: PersistenceController = {
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
            print("Saved Preview lists")
        } catch let error as NSError {
            print("Error trying to save preview list data: \(error), \(error.userInfo)")
            NSLog("Error trying to save preview list data: \(error), \(error.userInfo)")
        }

        return resultList
    }()
    #endif
}
