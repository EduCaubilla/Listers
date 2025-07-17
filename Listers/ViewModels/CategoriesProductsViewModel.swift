//
//  CategoriesProductsViewModel.swift
//  Listers
//
//  Created by Edu Caubilla on 4/7/25.
//

import SwiftUI
import CoreData
import Combine

class CategoriesProductsViewModel: ObservableObject {
    //MARK: - PROPERTIES
    private let persistenceManager : any PersistenceManagerProtocol
    static let shared = CategoriesProductsViewModel()

    @Published var selectedList: DMList?

    @Published var categories: [DMCategory] = []
    @Published var products: [DMProduct] = []
    @Published var productsByCategory: [DMProduct] = []
    @Published var productNames: [String] = []

    @Published var selectedCategory: DMCategory?
    @Published var selectedProduct: DMProduct?

    @Published var showingAddProductView: Bool = false
    @Published var showingEditProductView: Bool = false
    @Published var showingDuplicateProductView: Bool = false
    @Published var showingListSelectionToAddProductView: Bool = false

    @Published var showAddedToListAlert: Bool = false
    @Published var showAddedToSelectedListAlert: Bool = false
    @Published var showEditedAlert: Bool = false
    @Published var showConfirmationToRemoveAlert: Bool = false

    @Published var activeAlert: ProductAlert?

    //MARK: - INITIALIZER
    init(persistenceManager: any PersistenceManagerProtocol = PersistenceManager.shared) {
        self.persistenceManager = persistenceManager
        loadCategoriesProductsData()
    }

    //MARK: - FUNCTIONS
    func loadCategoriesProductsData() {
        print("\nLoad Init Data CategoriesProductsViewModel -->")
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
            print("Loaded active products in view model \(products.count)")

            productNames = getProductNames()
        }
    }

    func getFavoriteProducts(for category: DMCategory,inCase showFavoritesOnly: Bool) -> [DMProduct] {
        let productsFetched = getProductsByCategory(category)

        if category.favorite, showFavoritesOnly {
            return productsFetched.filter({ $0.favorite })
        } else if !showFavoritesOnly {
            return productsFetched
        }

        return []
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
            let activeProducts = productsFetched.filter({ $0.active })
            let resultProducts = activeProducts.sorted { $0.name! < $1.name! }
            return resultProducts
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

    func addProductToList(_ product: DMProduct) {
        if selectedList == nil {
            setSelectedList()
        }

        print("Add product: \(product.name!) to list: \(selectedList?.name ?? "Unknown list")")

        persistenceManager.createItem(
            name: product.name!,
            description: product.note,
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
        saveCategoriesProductsUpdates()
    }

    func saveNewProduct(name: String, description: String?, categoryId: Int, active: Bool, favorite: Bool) {
        persistenceManager.createProduct(
            id: createIdForNewProduct(),
            name: name,
            note: description ?? "",
            categoryId: Int16(categoryId),
            active: active,
            favorite: favorite,
            custom: true,
            selected: true
        )
        saveCategoriesProductsUpdates()
    }

    func duplicate(product: DMProduct) -> Int {
        product.selected = false

        let newId = createIdForNewProduct()

        persistenceManager.createProduct(
            id: newId,
            name: product.name!,
            note: product.note,
            categoryId: Int16(product.categoryId),
            active: product.active,
            favorite: product.favorite,
            custom: true,
            selected: true
        )
        saveCategoriesProductsUpdates()

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
