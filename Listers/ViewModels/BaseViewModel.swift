//
//  BaseViewModel.swift
//  Listers
//
//  Created by Edu Caubilla on 21/7/25.
//

import SwiftUI
import CoreData

class BaseViewModel: ObservableObject {
    //MARK: - PROPERTIES
    let persistenceManager : any PersistenceManagerProtocol

    @Published var selectedList: DMList?

    @Published var products: [DMProduct] = []
    @Published var productNames: [String] = []

    @Published var activeAlert: ProductAlertManager?

    @Published var showingAddItemView : Bool = false
    @Published var showingUpdateItemView : Bool = false
    @Published var showingAddListView : Bool = false
    @Published var showingUpdateListView : Bool = false

    @Published var showingAddProductView: Bool = false
    @Published var showingUpdateProductView: Bool = false
    @Published var showingListToAddProductView: Bool = false

    //MARK: - INITIALIZER
    init(persistenceManager: any PersistenceManagerProtocol = PersistenceManager.shared) {
        self.persistenceManager = persistenceManager
        print("Init BaseViewmodel -------->")
    }

    //MARK: - FUNCTIONS

    //MARK: - PRODUCTS
    func fetchProducts() {
        let productsResult = persistenceManager.fetchAllActiveProducts()
        if let productsFetched = productsResult {
            products = productsFetched
            print("Loaded active products in view model \(products.count)")

            loadProductNames()
        }
    }

    func loadProductNames(forceLoad : Bool = false) {
        if productNames.isEmpty || forceLoad {
            if products.isEmpty {
                guard let productsResult = persistenceManager.fetchAllActiveProducts() else { return }
                products = productsResult
            } else {
                DispatchQueue.main.async {
                    self.productNames = self.products.map { $0.name ?? "Unknown Product Name" }
                }
                print("Product names loaded: \(productNames.count)")
            }
        }
    }

    func saveNewProduct(name: String, description: String?, categoryId: Int, active: Bool, favorite: Bool, then refresh: () -> Void) -> Int {
        var responseProductId : Int = -1
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
            refresh()
            responseProductId = newProductId
        } else {
            print("There was an error creating the product: \(name) with id: \(newProductId).")
        }
        return responseProductId
    }

    func createIdForNewProduct() -> Int {
        return persistenceManager.fetchNextProductId()
    }

    //MARK: - PERSISTENCE
    func saveChanges(then refresh: () -> Void) {
        let persistenceSaved = persistenceManager.savePersistence()

        if persistenceSaved {
            print("Context saved successfully.")
            refresh()
        } else {
            print("There was an error saving context.")
        }
    }

    func delete<T: NSManagedObject>(_ object: T, then refreshData: () -> Void = {}) {
        let objectDeleted = persistenceManager.remove(object)

        if objectDeleted {
            print("Object \(object) deleted successfully.")
            refreshData()
        } else {
            print("There was an error deleting object \(object).")
        }
    }

    //MARK: - FORM VIEW STATE
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
            case .openAddProduct:
                showingAddProductView = true
            case .closeAddProduct:
                showingAddProductView = false
            case .openUpdateProduct:
                showingUpdateProductView = true
            case .closeUpdateProduct:
                showingUpdateProductView = false
            case .openListSelectionToAddProduct:
                showingListToAddProductView = true
            case .closeListSelectionToAddProduct:
                showingListToAddProductView = false
        }
        print("On change form view state -> \(state) ---- ")
    }
}
