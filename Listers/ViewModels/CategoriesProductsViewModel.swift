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
    @Published var categories: [DMCategory] = []

    @Published var selectedCategory: DMCategory?
    @Published var selectedProduct: DMProduct?

    //MARK: - INITIALIZER
    override init(persistenceManager: any PersistenceManagerProtocol = PersistenceManager.shared) {
        super.init(persistenceManager: persistenceManager)
        loadCategoriesProductsData()
    }

    //MARK: - FUNCTIONS

    //MARK: - CATEGORIES
    func loadCategoriesProductsData() {
        print("\nLoad Init Data CategoriesProductsViewModel -->")
        fetchCategories()
        super.fetchProducts()
        print("All products loaded")
    }

    func fetchCategories() {
        let categoriesResult = persistenceManager.fetchAllCategories()
        guard let categoriesFetched = categoriesResult else {
            print("Fetch categories failed")
            return
        }

        categories = categoriesFetched
        print("Loaded categories in view model: \(categories.count)")
    }

    func getCategoryIdByProductName(_ name: String) -> Int16? {
        guard !products.isEmpty, !name.isEmpty else {
            return nil
        }

        return products.first(where: { $0.name == name })?.categoryId
    }

    func getCategoryByProductId(_ productId: Int16) -> DMCategory? {
        guard let categoryFetched = persistenceManager.fetchCategoryByProductId(productId) else {
            return nil
        }

        return categoryFetched
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
        saveCategoriesProductsUpdates()
        refreshCategoriesProductsData()
    }

    //MARK: - PRODUCTS
    func getProductsByCategory(_ category: DMCategory) -> [DMProduct] {
        guard let productsFetched = persistenceManager.fetchProductsByCategory(category) else {
            return []
        }

        let activeProducts = productsFetched.filter({ $0.active })
        let resultProducts = activeProducts.sorted { $0.name! < $1.name! }
        return resultProducts

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

    func saveProduct(name: String, description: String?, categoryId: Int, active: Bool, favorite: Bool) -> Int {
        let updateState: () -> Void = { [weak self] in
            self?.saveCategoriesProductsUpdates()
            self?.fetchProducts()
        }
        return super.saveNewProduct(name: name, description: description, categoryId: categoryId, active: active, favorite: favorite, then: updateState)
    }

    func duplicate(product: DMProduct) -> Int {
        product.selected = false

        return saveProduct(name: product.name!, description: product.notes, categoryId: Int(product.categoryId), active: product.active, favorite: product.favorite)
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

        if (!products.isEmpty) {
            guard let productSelected = products.filter({ $0.selected }).first else {
                selectedProduct = nil
                return
            }
            selectedProduct = productSelected
        } else {
            selectedProduct = product
        }

        print("Set Selected Product: \(String(describing: product.name))")
    }

    func addProductToList(_ product: DMProduct) -> Bool {
        var addedProductResponse = false

        let confirmListSelected = confirmListSelected()
        if !confirmListSelected {
            print("There's no list selected to add a product.")
        }

        print("Add product: \(product.name!) to list: \(selectedList?.name ?? "Unknown list")")

        guard let selectedListId = selectedList?.id else {
            print("There's no list selected or selected list has an issue to add a product.")
            return false
        }

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
            listId: selectedListId
        )

        if productToAddCreated {
            print("Product created added successfully.")
            saveCategoriesProductsUpdates()
            addedProductResponse = true
        } else {
            print("There was an error creating the product to add.")
        }

        return addedProductResponse
    }

    func scrollToFoundProduct(proxy: ScrollViewProxyProtocol, name: String = "", id: Int = 0) {
        var productsToScroll: [DMProduct] = []

        productsToScroll = !name.isEmpty ? products.filter { $0.name == name } : products.filter { $0.id == id }

        guard let productToScroll = productsToScroll.first else {
            print("Product to scroll to with id \(id) not found.")
            return
        }

        guard let categoryToScroll = getCategoryByProductId(productToScroll.id) else {
            print("Category to scroll to not found with id: \(productToScroll.id)")
            return
        }

        for category in categories {
            if category.id == categoryToScroll.id {
                print("Category to expand: \(String(describing: category.name))")
                category.expanded = true
            } else {
                print("Category to NOT expand: \(String(describing: category.name))")
                category.expanded = false
            }
        }
        saveCategoriesProductsUpdates()
        setSelectedProduct(productToScroll)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard self != nil else { return }
            withAnimation(.default){
                proxy.scrollTo(productToScroll.id, anchor: .center)
                print("Scroll to found product: \(productToScroll.name ?? "Unknown") with id: \(productToScroll.id)")
            }
        }
    }

    //MARK: - LISTS
    func confirmListSelected() -> Bool {
        return selectedList == nil ? getSelectedList() : true
    }

    private func getSelectedList() -> Bool {
        guard let selectedListFetched = persistenceManager.fetchSelectedList() else {
            print("There was no selected list found. Setting the first one as selected.")
            return setDefaultSelectedList()
        }
        selectedListFetched.selected = true
        selectedList = selectedListFetched
        return true
    }

    private func setDefaultSelectedList() -> Bool {
        if let firstListFetched = persistenceManager.fetchAllLists()?.first {
            firstListFetched.selected = true
            selectedList = firstListFetched
            return persistenceManager.savePersistence()
        }
        return false
    }

    //MARK: - COMMON
    func saveCategoriesProductsUpdates() {
        super.saveChanges(then: refreshCategoriesProductsData)
    }

    func delete<T: NSManagedObject>(_ object: T) {
        super.delete(object, then: refreshCategoriesProductsData)
    }

    private func refreshCategoriesProductsData() {
        super.fetchProducts()
        fetchCategories()
    }
}
