//
//  ContentViewViewModel.swift
//  Listers
//
//  Created by Edu Caubilla on 27/6/25.
//

import SwiftUI
import CoreData

@MainActor
class MainItemsListsViewModel: ObservableObject {
    //MARK: - PROPERTIES
    private let persistenceManager : any PersistenceManagerProtocol

    @Published var selectedList: DMList?
    @Published var itemsOfSelectedList: [DMItem] = []
    @Published var lists: [DMList] = []

    @Published var productNames: [String] = []

    @Published var showingAddItemView : Bool = false
    @Published var showingUpdateItemView : Bool = false
    @Published var showingAddListView : Bool = false

    var isListEmpty: Bool {
        lists.isEmpty
    }

    //MARK: - INITIALIZER
    init(persistenceManager: any PersistenceManagerProtocol = PersistenceManager.shared) {
        self.persistenceManager = persistenceManager
        loadListsItemsData()
    }

    //MARK: - FUNCTIONS
    func loadListsItemsData() {
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
        print("Lists fetched: \(listsResult?.count ?? 0)")
        if let listsResult = listsResult {
            self.lists = listsResult
            return
        } else {
            lists = []
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
        if list.id != nil {
            return persistenceManager.fetchItemsForList(withId: list.id!) ?? []
        }
        return []
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
        refreshItemsListData()
    }

    func delete<T: NSManagedObject>(_ object: T) {
        persistenceManager.remove(object)
        refreshItemsListData()
    }

    private func refreshItemsListData() {
        fetchLists()
        loadItemsForSelectedList()
    }

    func getProductNames() -> [String] {
        var productNameList: [String] = []

        let productsResult = persistenceManager.fetchAllProducts()
        if let products = productsResult {
            for product in products {
                productNameList.append(product.name!)
            }
        }

        return productNameList
    }

    func setProductNames() {
        productNames = getProductNames()
        print("Product names set in MainItemsListsViewModel : \(productNames.count)")
    }
}
