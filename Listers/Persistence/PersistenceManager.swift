//
//  PersistenceManager.swift
//  Listers
//
//  Created by Edu Caubilla on 13/6/25.
//

import CoreData
import Combine
import SwiftUI

class PersistenceManager: ObservableObject {
    @Published var itemsList: [DMItem] = []

    @Published var name: String = ""
    @Published var note: String = ""
    @Published var completed: Bool = false
    @Published var favorite: Bool = false
    @Published var date: Date = Date.now
    @Published var endDate: Date = Date()
    @Published var priority: String = "Normal"
    @Published var image: String = ""
    @Published var link: String = ""


    @FetchRequest(
        entity: DMItem.entity(),
        sortDescriptors: [],
        animation: .default)
    var items: FetchedResults<DMItem>

    var body: some View {
        NavigationStack {
            List(items) { item in
                Text(item.name ?? "Unknown")
            }
            .navigationTitle(Text("Listers"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    init() {
        loadItems()
    }

    //MARK: - ITEMS
    func loadItems() {
        items.map { item in
            itemsList.append(item)
        }
        print(itemsList)
    }

    func createItem(context:NSManagedObjectContext) {
        let newItem = DMItem(context: context)
        newItem.id = UUID()
        newItem.name = name
        newItem.note = note
        newItem.completed = completed
        newItem.favorite = favorite
        newItem.timestamp = date
        newItem.endDate = endDate
        newItem.priority = priority
        newItem.image = image
        newItem.link = link

        saveItem(context: context)
    }

    func saveItem(context:NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Item could not be saved. Error: \(nsError), \(nsError.userInfo)")
        }
    }

    func deleteItem(context:NSManagedObjectContext, offsets: IndexSet) {
        offsets.map { items[$0] }.forEach(context.delete)
    }

    func updateItem(context:NSManagedObjectContext) {

    }

    //MARK: - LISTS -> TODO


    //MARK: - PRODUCTS -> TODO


}
