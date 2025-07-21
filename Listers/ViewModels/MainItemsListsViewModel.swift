//
//  ContentViewViewModel.swift
//  Listers
//
//  Created by Edu Caubilla on 27/6/25.
//

import SwiftUI
import CoreData
import Combine

class MainItemsListsViewModel: ObservableObject {
    //MARK: - PROPERTIES
    private let persistenceManager : any PersistenceManagerProtocol
    private var cancellables = Set<AnyCancellable>()

    let settingsManager = SettingsManager.shared
    var userSettings : DMSettings? = nil

    var currentScreen : NavRoute = .main

    @Published var selectedList: DMList?
    @Published var itemsOfSelectedList: [DMItem] = []
    @Published var lists: [DMList] = []

    @Published var productNames: [String] = []

    @Published var showingAddItemView : Bool = false
    @Published var showingUpdateItemView : Bool = false
    @Published var showingAddListView : Bool = false
    @Published var showingUpdateListView : Bool = false

    @Published var showSaveNewProductMessage: Bool = false
    @Published var showCompletedListMessage: Bool = false

    var isListEmpty: Bool {
        lists.isEmpty
    }

    var hasSelectedList: Bool {
        selectedList != nil
    }

    var selectedListName: String {
        selectedList?.name ?? ""
    }

    var isItemDescriptionVisible: Bool {
        userSettings?.itemDescription ?? false
    }

    var isItemQuantityVisible: Bool {
        userSettings?.itemQuantity ?? false
    }

    var isItemEndDateVisible: Bool {
        userSettings?.itemEndDate ?? false
    }

    var isListDescriptionVisible: Bool {
        userSettings?.listDescription ?? false
    }

    var isListEndDateVisible: Bool {
        userSettings?.listEndDate ?? false
    }

    //MARK: - INITIALIZER
    init(persistenceManager: any PersistenceManagerProtocol = PersistenceManager.shared) {
        self.persistenceManager = persistenceManager

        setupSelectedListDataBinding()
        loadListsItemsData()
    }

    //MARK: - FUNCTIONS
    private func setupSelectedListDataBinding() {
        $selectedList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadItemsForSelectedList()
            }
            .store(in: &cancellables)
    }

    func loadListsItemsData() {
        print("\n------\n\nLoad Init Data VM ----->")

        loadLists()

        guard !isListEmpty else {
            print ("Lists is empty")
            return
        }

        loadProductNames()
        checkSelectedList()
        loadItemsForSelectedList()
    }

    func loadLists() {
        let listsResult = persistenceManager.fetchAllLists()
        print("Lists fetched: \(listsResult?.count ?? 0)")

        if let listsResult = listsResult {
            listsResult.forEach { _ = persistenceManager.setListCompleteness(for: $0.id!) }
            // Sort - Pinned first ordered by date, if it has, and then by name, then the unpinned with same date/name order
            let sortedItems = listsResult.sorted {
                ($0.pinned ? 0 : 1, $0.creationDate ?? .distantFuture, $0.name?.lowercased() ?? "")
                <
                ($1.pinned ? 0 : 1, $1.creationDate ?? .distantFuture, $1.name?.lowercased() ?? "")
            }
            self.lists = sortedItems
            return
        } else {
            lists = []
            print("There are no lists.")
        }
    }

    private func checkSelectedList() {
        if(selectedList == nil) {
            setSelectedList()
        }
    }

    private func setSelectedList() {
        if lists.isEmpty { return }

        selectedList = lists.first(where: { $0.selected })

        if selectedList == nil && !lists.isEmpty {
            setDefaultSelectedList()
        }

        print("Set selected List \(String(describing: selectedList?.name))")
    }

    func loadItemsForSelectedList() {
        guard let selectedListId = selectedList?.id else {
            print("There's no list selected")
            return
        }

        let itemsResult = persistenceManager.fetchItemsForList(withId: selectedListId)
        if let itemsResult = itemsResult {
            let sortedItems = itemsResult.sorted { !$0.completed && $1.completed }
            itemsOfSelectedList = sortedItems
        } else {
            print("There are no items in the selected list.")
        }
    }

    func updateSelectedList(_ newList: DMList) {
        selectedList = newList
        lists.forEach { $0.selected = $0.id == newList.id }
        saveItemListsChanges()
    }

    private func setDefaultSelectedList() {
        guard !lists.isEmpty else { return }

        selectedList = lists[0]
        lists[0].selected = true
        saveItemListsChanges()
    }

    func fetchItemsForList(_ list: DMList) -> [DMItem] {
        if list.id != nil {
            return persistenceManager.fetchItemsForList(withId: list.id!) ?? []
        }
        return []
    }

    func checkListCompletedStatus() {
        var isListCompleted = false
        if let selectedListId = selectedList?.id {
            isListCompleted = persistenceManager.setListCompleteness(for: selectedListId)
        }
        refreshItemsListData()

        if isListCompleted && currentScreen == .main {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                showCompletedListMessage = true
            }
        }
    }

    func loadSettings() {
        if let userSettings = settingsManager.currentSettings {
            self.userSettings = userSettings
        } else {
            settingsManager.loadSettings()
        }
        print("Settings loaded from MainItemsListsViewModel")
        print(userSettings ?? "")
    }

    func loadProductNames(){
        if productNames.isEmpty {
            let productsResult = persistenceManager.fetchAllProducts()
            if let products = productsResult {
                productNames = products.map { $0.name! }
                print("Product names loaded: \(productNames.count)")
            }
        }
    }

    func createIdForNewProduct() -> Int {
        let newId = persistenceManager.fetchLastProductId()
        return newId != 0 ? newId + 1 : 0
    }

    func saveNewProduct(name: String, description: String?, categoryId: Int, active: Bool, favorite: Bool) {
        let newProductId = createIdForNewProduct()

        let createdProduct = persistenceManager.createProduct(
            id: newProductId,
            name: name,
            notes: description ?? "",
            categoryId: Int16(categoryId),
            active: active,
            favorite: favorite,
            custom: true,
            selected: true
        )

        if createdProduct {
            print("New product created: \(name) with id: \(newProductId)")
            saveItemListsChanges()
        } else {
            print("There was an error creating the product: \(name) with id: \(newProductId).")
        }
    }

    func addList(name: String, description: String, creationDate: Date, endDate: Date?, pinned: Bool, selected: Bool, expanded: Bool) {
        let createdList = persistenceManager.createList(
                name: name,
                description: description,
                creationDate: creationDate,
                endDate: endDate,
                pinned: pinned,
                selected: selected,
                expanded: expanded,
                completed: false
        )

        if createdList {
            print("List \(name) created successfully.")
            saveItemListsChanges()
        } else {
            print("There was an error creating the List \(name).")
        }
    }

    func addItemToList(name: String, description: String?, quantity: Double, favorite: Bool, priority: Priority, completed: Bool, selected: Bool, creationDate: Date, endDate: Date?, image: String?, link: String?, listId: UUID?) {
        let createdItem = persistenceManager.createItem(
                name: name,
                description: description,
                quantity: quantity,
                favorite: favorite,
                priority: priority,
                completed: completed,
                selected: selected,
                creationDate: creationDate,
                endDate: endDate,
                image: image,
                link: link,
                listId: listId
            )

        if createdItem {
            print("Item \(name) created successfully.")
            saveItemListsChanges()
        } else {
            print("There was an error creating the Item \(name).")
        }
    }

    private func refreshItemsListData() {
        loadLists()
        loadItemsForSelectedList()
    }

    func saveItemListsChanges() {
        let persistenceSaved = persistenceManager.savePersistence()

        if persistenceSaved {
            print("Context saved successfully.")
            refreshItemsListData()
        } else {
            print("There was an error saving context.")
        }
    }

    func deleteList(_ listForDelete: DMList) {
        let itemsToDelete = itemsOfSelectedList.filter { $0.listId == listForDelete.id }
        for item in itemsToDelete {
            delete(item)
        }

        let itemsRemainingInList = fetchItemsForList(listForDelete)
        if itemsRemainingInList.isEmpty {
            delete(listForDelete)
        }
    }

    func delete<T: NSManagedObject>(_ object: T) {
        let objectDeleted = persistenceManager.remove(object)

        if objectDeleted {
            print("Object \(object) deleted successfully.")
            refreshItemsListData()
        } else {
            print("There was an error deleting object \(object).")
        }
    }

    func changeFormViewState(to state: FormViewAction) {
        switch state {
            case .openAddItem:
                showingAddItemView = true
            case .closeAddItem:
                showingAddItemView = false
            case .openUpdateItem:
                showingUpdateItemView = true
            case .closeUpdateItem:
                showingUpdateItemView = false
            case .openAddList:
                showingAddListView = true
            case .closeAddList:
                showingAddListView = false
            case .openUpdateList:
                showingUpdateListView = true
            case .closeUpdateList:
                showingUpdateListView = false
        }
    }
}
