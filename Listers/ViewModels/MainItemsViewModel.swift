//
//  ContentViewViewModel.swift
//  Listers
//
//  Created by Edu Caubilla on 27/6/25.
//

import SwiftUI
import CoreData

class MainItemsViewModel: ObservableObject {
    //MARK: - PROPERTIES
    @Published var selectedList: DMList?
    @Published var itemsOfSelectedList: [DMItem] = []
    @Published var lists: [DMList] = []
    @Published var isListEmpty: Bool = true

    @Published var showingAddItemView : Bool = false
    @Published var showingUpdateItemView : Bool = false
    @Published var showingAddListView : Bool = false

    private let persistenceManager : any PersistenceManagerProtocol

    //MARK: - INITIALIZER
    init(persistenceManager: any PersistenceManagerProtocol = PersistenceManager.shared) {
        self.persistenceManager = persistenceManager
        loadInitData()
    }

    //MARK: - FUNCTIONS
    func loadInitData() {
        print("\n------\n\nLoad Init Data VM ----->")

        fetchLists()

        guard !isListEmpty else {
            print ("Lists is empty")
            return
        }

        checkSelectedList()

        guard selectedList != nil else {
            print ("There's no selected list")
            setDefaultSelectedList()
            return
        }

        loadItemsForSelectedList()
    }

    func fetchLists() {
        let listsResult = persistenceManager.fetchAllLists()
        print("Lists fetched: \(listsResult?.count ?? 0) -->")
        if let listsResult = listsResult {
            self.lists = listsResult
            isListEmpty = listsResult.isEmpty
            lists.forEach { print($0.name ?? "Unknown") }
            print("----")
            return
        } else {
            print("There are no lists.")
        }
    }

    func checkSelectedList() {
        if(selectedList == nil) {
            setSelectedList()
        }
    }

    func setSelectedList() {
        if lists.isEmpty { return }

        selectedList = lists.first(where: { $0.selected })

        if selectedList == nil && !lists.isEmpty {
            setDefaultSelectedList()
        }

        print("Set selected List \(String(describing: selectedList?.name))")
    }

    func setDefaultSelectedList() {
        if !lists.isEmpty {
            selectedList = lists[0]
            lists[0].selected = true
            saveUpdates()
        }
    }

    func updateSelectedList(_ newList: DMList) {
        selectedList = newList
        lists.forEach { $0.selected = $0.id == newList.id }
        saveUpdates()
    }

    func loadItemsForSelectedList() {
        guard let selectedListId = selectedList?.id else {
            print("There's no list selected")
            return
        }

        let itemsResult = persistenceManager.fetchItemsForList(withId: selectedListId)
        if let itemsResult = itemsResult {
            itemsOfSelectedList = itemsResult
        } else {
            print("There are no items in the selected list.")
        }
    }

    func fetchItemsForList(_ list: DMList) -> [DMItem] {
        return persistenceManager.fetchItemsForList(withId: list.id!) ?? []
    }

    func addList(name: String, description: String, creationDate: Date, endDate: Date?, pinned: Bool, selected: Bool, expanded: Bool) {
        _ = persistenceManager.createList(name: name, description: description, creationDate: creationDate, endDate: endDate, pinned: pinned, selected: selected, expanded: expanded)
        saveUpdates()
    }

    func addItem(name: String, description: String?, quantity: Int16, favorite: Bool, priority: Priority, completed: Bool, selected: Bool, creationDate: Date, endDate: Date?, image: String?, link: String?, listId: UUID?) {
        _ = persistenceManager.createItem(name: name, description: description, quantity: quantity, favorite: favorite, priority: priority, completed: completed, selected: selected, creationDate: creationDate, endDate: endDate, image: image, link: link, listId: listId)
        saveUpdates()
    }

    func saveUpdates() {
        persistenceManager.savePersistence()
        refreshData()
    }

    func delete<T: NSManagedObject>(_ object: T) {
        persistenceManager.remove(object)
        refreshData()
    }

    private func refreshData() {
        fetchLists()
        loadItemsForSelectedList()
    }
}
