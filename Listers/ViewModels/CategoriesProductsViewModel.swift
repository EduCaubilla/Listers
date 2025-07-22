//
//  CategoriesProductsViewModel.swift
//  Listers
//
//  Created by Edu Caubilla on 4/7/25.
//

import SwiftUI
import CoreData
import Combine

class CategoriesProductsViewModel: BaseViewModel {
    //MARK: - PROPERTIES
    static let shared = CategoriesProductsViewModel()

    @Published var categories: [DMCategory] = []

    @Published var selectedCategory: DMCategory?
    @Published var selectedProduct: DMProduct?

    @Published var showAddedToListAlert: Bool = false
    @Published var showAddedToSelectedListAlert: Bool = false
    @Published var showEditedAlert: Bool = false
    @Published var showConfirmationToRemoveAlert: Bool = false

    //MARK: - INITIALIZER
    init() {
        super.init()
        Task { await loadCategoriesProductsData() }
    }

    //MARK: - FUNCTIONS
    @MainActor
    func loadCategoriesProductsData() {
        print("\nLoad Init Data CategoriesProductsViewModel -->")
        Task {
            fetchCategories()
            super.fetchProducts()
        }
        print("All products loaded")
    }

    @MainActor
    func fetchCategories() {
        let categoriesResult = persistenceManager.fetchAllCategories()
        if let categoriesFetched = categoriesResult {
            categories = categoriesFetched
            print("Loaded categories in view model: \(categories.count)")
        }
    }

    @MainActor
    func getFavoriteProducts(for category: DMCategory,inCase showFavoritesOnly: Bool) -> [DMProduct] {
        let productsFetched = getProductsByCategory(category)

        if category.favorite, showFavoritesOnly {
            return productsFetched.filter({ $0.favorite })
        } else if !showFavoritesOnly {
            return productsFetched
        }

        return []
    }

    func getProductsByCategory(_ category: DMCategory) -> [DMProduct] {
        if let productsFetched = persistenceManager.fetchProductsByCategory(category) {
            let activeProducts = productsFetched.filter({ $0.active })
            let resultProducts = activeProducts.sorted { $0.name! < $1.name! }
            return resultProducts
        }
        return []
    }

    func addProductToList(_ product: DMProduct) {
        if selectedList == nil {
            setSelectedList()
        }

        print("Add product: \(product.name!) to list: \(selectedList?.name ?? "Unknown list")")

        let productToAddCreated = persistenceManager.createItem(
            name: product.name!,
            description: product.notes,
            quantity: 0,
            favorite: product.favorite,
            priority: .normal,
            completed: false,
            selected: false,
            creationDate: Date.now,
            endDate: Date.now,
            image: "",
            link: "",
            listId: selectedList?.id
        )

        if productToAddCreated {
            print("Product created added successfully.")
            saveCategoriesProductsUpdates()
        } else {
            print("There was an error creating the product to add.")
        }
    }

    func saveProduct(name: String, description: String?, categoryId: Int, active: Bool, favorite: Bool) {
        let updateState: () -> Void = {
            self.saveCategoriesProductsUpdates()
            Task { await self.fetchProducts() }
        }
        super.saveNewProduct(name: name, description: description, categoryId: categoryId, active: active, favorite: favorite, then: updateState)
    }

    func duplicate(product: DMProduct) -> Int {
        product.selected = false

        let newId = super.createIdForNewProduct()

        let productDuplicated = persistenceManager.createProduct(
            id: newId,
            name: product.name!,
            notes: product.notes,
            categoryId: Int16(product.categoryId),
            active: product.active,
            favorite: product.favorite,
            custom: true,
            selected: true
        )

        if productDuplicated {
            print("Product duplicated successfully.")
            saveCategoriesProductsUpdates()
        } else {
            print("There was an error duplicating the product.")
        }

        return newId
    }

    func getProductById(_ id: Int) -> DMProduct? {
        return products.first(where: { $0.id == id })
    }

    func setSelectedProduct(_ product: DMProduct) {
        products = products.map {
            let newProduct = $0
            newProduct.selected = $0.id == product.id
            return newProduct
        }

        let productSelected = products.filter { $0.selected }.first!
        print(productSelected)

        selectedProduct = product
        print("Set Selected Product: \(String(describing: product.name))")
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

    func getCategoryByProductId(_ productId: Int16) -> DMCategory? {
        if let categoryFetched = persistenceManager.fetchCategoryByProductId(productId) {
            return categoryFetched
        }

        return nil
    }

    func setFavoriteCategory() {
        for category in categories {
            let categoryProducts = getProductsByCategory(category)

            if categoryProducts.contains(where: { $0.favorite }) {
                print("Category \(String(describing: category.name)) is favorite")
                category.favorite = true
            } else {
                print("Category \(String(describing: category.name)) is NOT favorite")
                category.favorite = false
            }
        }
        refreshCategoriesProductsData()
    }

    private func setSelectedList() {
        if let selectedListFetched = getSelectedList() {
            selectedList = selectedListFetched
        } else {
            setDefaultSelectedList()
        }
    }

    private func getSelectedList() -> DMList? {
        return persistenceManager.fetchSelectedList()
    }

    private func setDefaultSelectedList() {
        if let fetchedSelectedList = persistenceManager.fetchSelectedList() {
            selectedList = fetchedSelectedList
        }
    }

    func saveCategoriesProductsUpdates() {
        super.saveChanges(and: refreshCategoriesProductsData)
    }

    func delete<T: NSManagedObject>(_ object: T) {
        super.delete(object, then: refreshCategoriesProductsData)
    }

    private func refreshCategoriesProductsData() {
        Task {
            await super.fetchProducts()
            await fetchCategories()
        }
    }
}
