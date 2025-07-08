//
//  CategoriesProductsViewModel.swift
//  Listers
//
//  Created by Edu Caubilla on 4/7/25.
//

import SwiftUI
import CoreData

class CategoriesProductsViewModel: ObservableObject {
    //MARK: - PROPERTIES
    private let persistenceManager : any PersistenceManagerProtocol

    @Published var categories: [DMCategory] = []
    @Published var products: [DMProduct] = []
    @Published var productsByCategory: [DMProduct] = []

    @Published var selectedCategory: DMCategory?
    @Published var selectedProduct: DMProduct?

    @Published var showingAddProductView: Bool = false
    @Published var showingEditProductView: Bool = false
    @Published var showingDuplicateProductView: Bool = false

    //MARK: - INITIALIZER
    init(persistenceManager: any PersistenceManagerProtocol = PersistenceManager.shared) {
        self.persistenceManager = persistenceManager
        loadCategoriesProductsData()
    }

    //MARK: - FUNCTIONS
    func loadCategoriesProductsData() {
        print("\nLoad Init Data VM CATPRO -->")
        fetchCategories()
        fetchProducts()
        print("All products loaded")
    }

    func fetchCategories() {
        let categoriesResult = persistenceManager.fetchAllCategories()
        if let categoriesFetched = categoriesResult {
            categories = categoriesFetched
            print("Loaded categories in view model")

            print(categories.count)
        }
    }

    func fetchProducts() {
        let productsResult = persistenceManager.fetchAllProducts()
        if let productsFetched = productsResult {
            products = productsFetched
            print("Loaded products in view model")

            print(products.count)
        }
    }

    func getProductsByCategory(_ category: DMCategory) -> [DMProduct] {
        let productsCategory = persistenceManager.fetchProductsByCategory(category)
        if let productsFetched = productsCategory {
            return productsFetched
        }
        return []
    }

    func getProductsByCategoryId(_ categoryId: Int16) -> [DMProduct] {
        let getCategoryPredicate = NSPredicate(format: "id == %d", categoryId)
        let selectedCategory = persistenceManager.fetch(type: DMCategory.self, predicate: getCategoryPredicate)?.first
        print(selectedCategory ?? "No category found")

        if let selectedCategory = selectedCategory {
            let productsCategory = persistenceManager.fetchProductsByCategory(selectedCategory)
            if let productsFetched = productsCategory {
                return productsFetched
            }
        }

        return []
    }

    func setProductsByCategory(_ category: DMCategory) {
        self.productsByCategory = getProductsByCategory(category)
    }

    func createIdForNewProduct() -> Int {
        let newId = persistenceManager.fetchLastProductId()
        return newId != 0 ? newId + 1 : 0
    }

    func saveNewProduct(id: Int, name: String, description: String?, categoryId: Int, active: Bool, favorite: Bool) {
        persistenceManager.createProduct(
            id: createIdForNewProduct(),
            name: name,
            note: description ?? "",
            categoryId: categoryId,
            active: active,
            favorite: favorite,
            custom: true
        )
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
        fetchCategories()
        // TODO - Update products from category containing the new/updated product to refresh view?
    }

}
