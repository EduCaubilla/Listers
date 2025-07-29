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
    init() {
        super.init()
        loadCategoriesProductsData()
    }

    //MARK: - FUNCTIONS
    func loadCategoriesProductsData() {
        print("\nLoad Init Data CategoriesProductsViewModel -->")
        fetchCategories()
        super.fetchProducts()
        print("All products loaded")
    }

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

    func addProductToList(_ product: DMProduct) -> Bool {
        var addedProductResponse = false

        let confirmListSelected = confirmListSelected()
        if !confirmListSelected {
            return addedProductResponse
        }

        print("Add product: \(product.name!) to list: \(selectedList?.name ?? "Unknown list")")

        if let selectedListId = selectedList?.id {
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
        }

        return addedProductResponse
    }

    func confirmListSelected() -> Bool {
        var listSelectedResponse = false
        if selectedList == nil {
            let setListSelected = setSelectedList()
            if setListSelected {
                listSelectedResponse = true
            }
        }
        return listSelectedResponse
    }

    func saveProduct(name: String, description: String?, categoryId: Int, active: Bool, favorite: Bool) -> Int {
        let updateState: () -> Void = {
            self.saveCategoriesProductsUpdates()
            self.fetchProducts()
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

    func scrollToFoundProduct(proxy: ScrollViewProxy, name : String) {
        let productsToScroll = products.filter { $0.name == name }

        guard let productToScroll = productsToScroll.first else {
            print("Product to scroll to not found: \(name)")
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.default){
                proxy.scrollTo(productToScroll.id, anchor: .center)
                print("Scroll to found product: \(name) with id: \(productToScroll.id)")
            }
        }
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

    private func setSelectedList() -> Bool {
        var response = false
        if let selectedListFetched = getSelectedList() {
            selectedList = selectedListFetched
            response = true
        } else {
            response = setDefaultSelectedList()
        }
        return response
    }

    private func getSelectedList() -> DMList? {
        return persistenceManager.fetchSelectedList()
    }

    private func setDefaultSelectedList() -> Bool {
        var response = false
        if let fetchedSelectedList = persistenceManager.fetchSelectedList() {
            selectedList = fetchedSelectedList
            response = true
        }
        return response
    }

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
