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

    private var cancellables = Set<AnyCancellable>()

    let settingsManager = SettingsManager.shared
    var userSettings : DMSettings? = nil

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
        loadInitData()
    }

    override init(persistenceManager: any PersistenceManagerProtocol = PersistenceManager.shared) {
        super.init(persistenceManager: persistenceManager)

        setupSelectedListDataBinding()
        loadInitData()
    }

    //MARK: - FUNCTIONS
    private func setupSelectedListDataBinding() {
        $selectedList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { await self?.loadItemsForSelectedList() }
            }
            .store(in: &cancellables)
    }

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

        let sortedItems = itemsResult.sorted { !$0.completed && $1.completed }
        itemsOfSelectedList = sortedItems
    }

    @MainActor
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

    func saveItemListsChanges() {
        super.saveChanges(then: refreshItemsListData)
    }

    func deleteList(_ listForDelete: DMList) {
        let itemsToDelete = itemsOfSelectedList.filter { $0.listId == listForDelete.id }
        for item in itemsToDelete {
            super.delete(item)
        }

        let itemsRemainingInList = fetchItemsForList(listForDelete)
        if itemsRemainingInList.isEmpty {
            super.delete(listForDelete)
        }
    }

    func delete<T: NSManagedObject>(_ object: T) {
        super.delete(object, then: refreshItemsListData)
    }

    private func refreshItemsListData() {
        Task {
            await loadLists()
            await loadItemsForSelectedList()
        }
    }
}
