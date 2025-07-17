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

    @Published var selectedList: DMList?
    @Published var itemsOfSelectedList: [DMItem] = []
    @Published var lists: [DMList] = []

    @Published var productNames: [String] = []

    @Published var showingAddItemView : Bool = false
    @Published var showingUpdateItemView : Bool = false
    @Published var showingAddListView : Bool = false

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

        checkSelectedList()
        loadItemsForSelectedList()
        loadProductNames()
    }

    func loadLists() {
        let listsResult = persistenceManager.fetchAllLists()
        print("Lists fetched: \(listsResult?.count ?? 0)")

        if let listsResult = listsResult {
            listsResult.forEach { persistenceManager.setListCompleteness(for: $0.id!) }
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

    func checkListCompletedStatus() {
        if let selectedListId = selectedList?.id {
            persistenceManager.setListCompleteness(for: selectedListId)
        }
        refreshItemsListData()
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
        persistenceManager.createProduct(
            id: newProductId,
            name: name,
            note: description ?? "",
            categoryId: Int16(categoryId),
            active: active,
            favorite: favorite,
            custom: true,
            selected: true
        )
        saveItemListsChanges()

        print("New product created: \(name) with id: \(newProductId)")
    }

    func addList(name: String, description: String, creationDate: Date, endDate: Date?, pinned: Bool, selected: Bool, expanded: Bool) {
        persistenceManager
            .createList(
                name: name,
                description: description,
                creationDate: creationDate,
                endDate: endDate,
                pinned: pinned,
                selected: selected,
                expanded: expanded,
                completed: false
            )
        saveItemListsChanges()
    }

    func addItemToList(name: String, description: String?, quantity: Double, favorite: Bool, priority: Priority, completed: Bool, selected: Bool, creationDate: Date, endDate: Date?, image: String?, link: String?, listId: UUID?) {
        persistenceManager
            .createItem(
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
        saveItemListsChanges()
    }

    private func refreshItemsListData() {
        loadLists()
        loadItemsForSelectedList()
    }

    func saveItemListsChanges() {
        persistenceManager.savePersistence()
        refreshItemsListData()
    }

    func delete<T: NSManagedObject>(_ object: T) {
        persistenceManager.remove(object)
        refreshItemsListData()
    }
}
