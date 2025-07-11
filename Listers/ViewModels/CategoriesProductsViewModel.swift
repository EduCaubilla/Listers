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
    @Published var productNames: [String] = []

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

            print("Loaded categories in view model: \(categories.count)")
        }
    }

    func fetchProducts() {
        let productsResult = persistenceManager.fetchAllProducts()
        if let productsFetched = productsResult {
            products = productsFetched
            productNames = getProductNames()

            print("Loaded products in view model \(products.count)")
        }
    }

    func getProductNames() -> [String] {
        var productNames: [String] = []
        for product in products {
            productNames.append(product.name!)
        }
        return productNames
    }

    func getProductsByCategory(_ category: DMCategory) -> [DMProduct] {
        if let productsFetched = persistenceManager.fetchProductsByCategory(category) {
            return productsFetched
        }
        return []
    }

    func getProductByCategoryId(_ categoryId: Int16) -> DMProduct? {
        if let productFetched = persistenceManager.fetchProductByCategoryId(categoryId) {
            return productFetched
        }
        return nil
    }

    func setProductsByCategory(_ category: DMCategory) {
        self.productsByCategory = getProductsByCategory(category)
    }

    func createIdForNewProduct() -> Int {
        let newId = persistenceManager.fetchLastProductId()
        return newId != 0 ? newId + 1 : 0
    }

    func getCategoryIdByProductName(_ name: String) -> Int16? {
        if !products.isEmpty,
            !name.isEmpty {
            if let product = products.first(where: { $0.name == name }) {
                return product.categoryId
            }
        }

        return nil
    }

    func saveNewProduct(name: String, description: String?, categoryId: Int, active: Bool, favorite: Bool) {
        persistenceManager.createProduct(
            id: createIdForNewProduct(),
            name: name,
            note: description ?? "",
            categoryId: Int16(categoryId),
            active: active,
            favorite: favorite,
            custom: true
        )
        saveUpdates()
    }

    func saveUpdates() {
        persistenceManager.savePersistence()
        refreshCategoriesProductsData()
    }

    func delete<T: NSManagedObject>(_ object: T) {
        persistenceManager.remove(object)
        refreshCategoriesProductsData()
    }

    private func refreshCategoriesProductsData() {
        fetchProducts()
        fetchCategories()
    }
}
