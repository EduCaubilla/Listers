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
    }

    func loadLists() {
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

    private func refreshItemsListData() {
        loadLists()
        loadItemsForSelectedList()
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
            itemsOfSelectedList = itemsResult
        } else {
            print("There are no items in the selected list.")
        }
    }

    func loadProductNames(){
        let productsResult = persistenceManager.fetchAllProducts()
        if let products = productsResult {
            productNames = products.map { $0.name! }
            print("Product names loaded: \(productNames.count)")
        }
    }

    func addList(name: String, description: String, creationDate: Date, endDate: Date?, pinned: Bool, selected: Bool, expanded: Bool) {
        _ = persistenceManager.createList(name: name, description: description, creationDate: creationDate, endDate: endDate, pinned: pinned, selected: selected, expanded: expanded)
        saveItemListsChanges()
    }

    func addItem(name: String, description: String?, quantity: Int16, favorite: Bool, priority: Priority, completed: Bool, selected: Bool, creationDate: Date, endDate: Date?, image: String?, link: String?, listId: UUID?) {
        _ = persistenceManager.createItem(name: name, description: description, quantity: quantity, favorite: favorite, priority: priority, completed: completed, selected: selected, creationDate: creationDate, endDate: endDate, image: image, link: link, listId: listId)
        saveItemListsChanges()
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
