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
    private func loadCategoriesProductsData() {
        fetchCategories()
    }

    private func fetchCategories() {
        let categoriesResult = persistenceManager.fetch(type: DMCategory.self, predicate: nil)
        if let categoriesFetched = categoriesResult {
            categories = categoriesFetched
        }
    }

    private func getProductsByCategory(_ category: DMCategory) -> [DMProduct] {
        let productsCategory = persistenceManager.fetchProductsByCategory(categoryId: Int(category.id))
        if let productsFetched = productsCategory {
            return productsFetched
        }
        return []
    }



}
