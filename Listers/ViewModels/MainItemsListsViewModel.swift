//
//  ContentViewViewModel.swift
//  Listers
//
//  Created by Edu Caubilla on 27/6/25.
//

import SwiftUI
import CoreData
import Combine


class MainItemsListsViewModel: BaseViewModel {
    //MARK: - PROPERTIES

    @Published var itemsOfSelectedList: [DMItem] = []
    @Published var lists: [DMList] = []

    @Published var showSaveNewProductAlert: Bool = false
    @Published var showCompletedListAlert: Bool = false

    @Published var sharedURL: URL?
    @Published var showShareSheet: Bool = false

    private var cancellables = Set<AnyCancellable>()

    let settingsManager = SettingsManager.shared
    var userSettings : DMSettings? = nil

    let dataManager = DataManager.shared

    var currentScreen : NavRoute = .main

    var isListsEmpty: Bool {
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
    init() {
        super.init()

        setupSelectedListDataBinding()
    }

    override init(persistenceManager: any PersistenceManagerProtocol = PersistenceManager.shared) {
        super.init(persistenceManager: persistenceManager)

        setupSelectedListDataBinding()
    }

    //MARK: - FUNCTIONS
    func loadInitData() {
        print("\n------\n\nLoad Init Data VM ----->")

        Task{
            await loadLists()

            guard !isListsEmpty else {
                print ("Lists is empty")
                return
            }

            await checkSelectedList()

            await loadItemsForSelectedList()
        }
    }

    //MARK: - LISTS
    private func setupSelectedListDataBinding() {
        $selectedList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { await self?.loadItemsForSelectedList() }
            }
            .store(in: &cancellables)
    }

    @MainActor
    func loadLists() {
        let listsResult : [DMList]? = persistenceManager.fetchAllLists()
        print("Lists fetched: \(listsResult?.count ?? 0)")

        guard let listsResult = listsResult else {
            lists = []
            print("There are no lists.")
            return
        }

        listsResult.forEach {
            guard let id = $0.id else { return }
            _ = persistenceManager.setListCompleteness(for: id)
        }
        // Sort - Pinned first ordered by date, if it has, and then by name, then the unpinned with same date/name order
        let sortedItems = listsResult.sorted {
            ($0.pinned ? 0 : 1, $0.creationDate ?? .distantFuture, $0.name?.lowercased() ?? "")
            <
            ($1.pinned ? 0 : 1, $1.creationDate ?? .distantFuture, $1.name?.lowercased() ?? "")
        }
        self.lists = sortedItems
    }

    @MainActor
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

    private func setDefaultSelectedList() {
        guard !lists.isEmpty else { return }

        selectedList = lists[0]
        lists[0].selected = true
        saveItemListsChanges()
    }

    @MainActor
    func updateSelectedList(_ newList: DMList) {
        selectedList = newList
        lists.forEach { $0.selected = $0.id == newList.id }
        saveItemListsChanges()
    }

    @MainActor
    func checkListCompletedStatus() {
        var isListCompleted = false
        if let selectedListId = selectedList?.id {
            isListCompleted = persistenceManager.setListCompleteness(for: selectedListId)
        }
        refreshItemsListData()

        if isListCompleted && currentScreen == .main {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                showCompletedListAlert = true
            }
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

    func addItemToList(name: String, description: String?, quantity: Int16, favorite: Bool, priority: Priority, completed: Bool, selected: Bool, creationDate: Date, endDate: Date?, image: String?, link: String?, listId: UUID?) {
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

    func deleteItemsOfList(_ listToDelete: DMList) {
        guard let itemsToDelete = persistenceManager.fetchItemsForList(withId: listToDelete.id!) else {
            print("No items found for given list ID.")
            return
        }

        for item in itemsToDelete {
            super.delete(item)
        }
    }

    func deleteList(_ listToDelete: DMList) {
        deleteItemsOfList(listToDelete)

        let itemsRemainingInList = fetchItemsForList(listToDelete)
        if itemsRemainingInList.isEmpty {
            super.delete(listToDelete)
        }
    }

    //MARK: - ITEMS
    @MainActor
    func loadItemsForSelectedList() {
        guard let selectedListId = selectedList?.id else {
            print("There's no list selected")
            return
        }

        let itemsResult = persistenceManager.fetchItemsForList(withId: selectedListId)
        guard let itemsResult = itemsResult else {
            print("There are no items in the selected list.")
            return
        }
        itemsOfSelectedList = itemsResult
    }

    func fetchItemsForList(_ list: DMList) -> [DMItem] {
        if list.id != nil {
            return persistenceManager.fetchItemsForList(withId: list.id!) ?? []
        }
        return []
    }

    //MARK: - OTHER
    func loadSettings() {
        if let userSettings = settingsManager.currentSettings {
            self.userSettings = userSettings
        } else {
            settingsManager.loadSettings()
        }
        print("Settings loaded from MainItemsListsViewModel")
    }

    func saveProduct(name: String, description: String?, categoryId: Int, active: Bool, favorite: Bool) {
        _ = super.saveNewProduct(name: name, description: description, categoryId: categoryId, active: active, favorite: favorite, then: saveItemListsChanges)
    }

    //MARK: - SHARING
    func shareList() {
        guard let currentList = selectedList else {
            print("No list selected to share.")
            return
        }

        if let url = dataManager.exportList(currentList) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.sharedURL = url
                self.showShareSheet = true
            }
        } else {
            print("List could not be shared.")
        }
    }

    //MARK: - COMMON
    func saveItemListsChanges() {
        super.saveChanges(then: refreshItemsListData)
    }

    func delete<T: NSManagedObject>(_ object: T) {
        super.delete(object, then: refreshItemsListData)
    }

    func refreshItemsListData() {
        Task {
            await loadLists()
            await loadItemsForSelectedList()
        }
    }
}
