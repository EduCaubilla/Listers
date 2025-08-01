//
//  CategoriesProductsViewModelTests.swift
//  ListersTests
//
//  Created by Edu Caubilla on 30/7/25.
//

import XCTest
import CoreData
import SwiftUI
import Combine
@testable import Listers

final class CategoriesProductsViewModelTests: XCTestCase {
    var sut: CategoriesProductsViewModel!
    var mockPersistenceManager: MockPersistenceManager!
    var mockPersistence: MockPersistence!
    var context: NSManagedObjectContext!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPersistenceManager = MockPersistenceManager()
        mockPersistence = MockPersistence()
        context = mockPersistence.makeInMemoryPersistentContainer().viewContext
        cancellables = Set<AnyCancellable>()

        sut = CategoriesProductsViewModel(persistenceManager: mockPersistenceManager)
    }

    override func tearDownWithError() throws {
        cancellables?.removeAll()
        sut = nil
        mockPersistenceManager = nil
        mockPersistence = nil
        context = nil
        cancellables = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testInit_ShouldInitializePropertiesWithDefaultValues() {
        // Arrange & Act & Assert
        XCTAssertTrue(sut.categories.isEmpty)
        XCTAssertNil(sut.selectedCategory)
        XCTAssertNil(sut.selectedProduct)
    }

    // MARK: - loadCategoriesProductsData Tests

    func testLoadCategoriesProductsData_ShouldFetchCategoriesAndProducts() {
        // Arrange
        let mockCategories = createMockCategories(count: 3, context: context)
        let mockProducts = createMockProducts(count: 5, context: context)
        mockPersistenceManager.mockCategories = mockCategories
        mockPersistenceManager.mockProducts = mockProducts

        // Act
        sut.loadCategoriesProductsData()

        // Assert
        XCTAssertTrue(mockPersistenceManager.fetchAllCategoriesCalled)
        XCTAssertTrue(mockPersistenceManager.fetchAllActiveProductsCalled)
        XCTAssertEqual(sut.categories.count, 3)
        XCTAssertEqual(sut.products.count, 5)
    }

    // MARK: - fetchCategories Tests

    func testFetchCategories_WhenCategoriesExist_ShouldLoadCategories() {
        // Arrange
        let mockCategories = createMockCategories(count: 2, context: context)
        mockPersistenceManager.mockCategories = mockCategories

        // Act
        sut.fetchCategories()

        // Assert
        XCTAssertEqual(sut.categories.count, 2)
        XCTAssertTrue(mockPersistenceManager.fetchAllCategoriesCalled)
    }

    func testFetchCategories_WhenNoCategoriesExist_ShouldNotLoadCategories() {
        // Arrange
        mockPersistenceManager.mockCategories = nil

        // Act
        sut.fetchCategories()

        // Assert
        XCTAssertTrue(sut.categories.isEmpty)
        XCTAssertTrue(mockPersistenceManager.fetchAllCategoriesCalled)
    }

    // MARK: - getCategoryIdByProductName Tests

    func testGetCategoryIdByProductName_WhenProductExists_ShouldReturnCategoryId() {
        // Arrange
        let mockProducts = createMockProducts(count: 3, context: context)
        mockProducts[1].name = "Test Product"
        mockProducts[1].categoryId = 42
        sut.products = mockProducts

        // Act
        let result = sut.getCategoryIdByProductName("Test Product")

        // Assert
        XCTAssertEqual(result, 42)
    }

    func testGetCategoryIdByProductName_WhenProductDoesNotExist_ShouldReturnNil() {
        // Arrange
        let mockProducts = createMockProducts(count: 3, context: context)
        sut.products = mockProducts

        // Act
        let result = sut.getCategoryIdByProductName("Non-existent Product")

        // Assert
        XCTAssertNil(result)
    }

    func testGetCategoryIdByProductName_WhenNameIsEmpty_ShouldReturnNil() {
        // Arrange
        let mockProducts = createMockProducts(count: 3, context: context)
        sut.products = mockProducts

        // Act
        let result = sut.getCategoryIdByProductName("")

        // Assert
        XCTAssertNil(result)
    }

    func testGetCategoryIdByProductName_WhenProductsArrayIsEmpty_ShouldReturnNil() {
        // Arrange
        sut.products = []

        // Act
        let result = sut.getCategoryIdByProductName("Any Product")

        // Assert
        XCTAssertNil(result)
    }

    // MARK: - getCategoryByProductId Tests

    func testGetCategoryByProductId_WhenCategoryExists_ShouldReturnCategory() {
        // Arrange
        let mockCategory = createMockCategory(id: 1, name: "Test Category", context: context)
        mockPersistenceManager.mockCategory = mockCategory

        // Act
        let result = sut.getCategoryByProductId(100)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, "Test Category")
        XCTAssertTrue(mockPersistenceManager.fetchCategoryByProductIdCalled)
    }

    func testGetCategoryByProductId_WhenCategoryDoesNotExist_ShouldReturnNil() {
        // Arrange
        mockPersistenceManager.mockCategory = nil

        // Act
        let result = sut.getCategoryByProductId(100)

        // Assert
        XCTAssertNil(result)
        XCTAssertTrue(mockPersistenceManager.fetchCategoryByProductIdCalled)
    }

    // MARK: - setFavoriteCategory Tests

    func testSetFavoriteCategory_WhenCategoryHasFavoriteProducts_ShouldSetCategoryAsFavorite() {
        // Arrange
        let mockCategory = createMockCategory(id: 1, name: "Test Category", context: context)
        let mockProducts = createMockProducts(count: 3, context: context)
        mockProducts[0].favorite = true
        mockProducts[0].categoryId = 1

        sut.categories = [mockCategory]
        mockPersistenceManager.mockProducts = mockProducts
        mockPersistenceManager.shouldSavePersistence = true

        // Act
        sut.setFavoriteCategory()

        // Assert
        XCTAssertTrue(mockCategory.favorite)
        XCTAssertTrue(mockPersistenceManager.savePersistenceCalled)
    }

    func testSetFavoriteCategory_WhenCategoryHasNoFavoriteProducts_ShouldSetCategoryAsNotFavorite() {
        // Arrange
        let mockCategory = createMockCategory(id: 1, name: "Test Category", context: context)
        let mockProducts = createMockProducts(count: 3, context: context)
        mockProducts.forEach { $0.favorite = false; $0.categoryId = 1 }

        sut.categories = [mockCategory]
        mockPersistenceManager.mockProducts = mockProducts
        mockPersistenceManager.shouldSavePersistence = true

        // Act
        sut.setFavoriteCategory()

        // Assert
        XCTAssertFalse(mockCategory.favorite)
        XCTAssertTrue(mockPersistenceManager.savePersistenceCalled)
    }

    // MARK: - getProductsByCategory Tests

    func testGetProductsByCategory_WhenProductsExist_ShouldReturnSortedActiveProducts() {
        // Arrange
        let mockCategory = createMockCategory(id: 1, name: "Test Category", context: context)
        let mockProducts = createMockProducts(count: 3, context: context)
        mockProducts[0].name = "Z Product"
        mockProducts[0].active = true
        mockProducts[1].name = "A Product"
        mockProducts[1].active = true
        mockProducts[2].name = "M Product"
        mockProducts[2].active = false // Should be filtered out

        mockPersistenceManager.mockProducts = mockProducts

        // Act
        let result = sut.getProductsByCategory(mockCategory)

        // Assert
        XCTAssertEqual(result.count, 2) // Only active products
        XCTAssertEqual(result[0].name, "A Product") // Sorted alphabetically
        XCTAssertEqual(result[1].name, "Z Product")
        XCTAssertTrue(mockPersistenceManager.fetchProductsByCategoryCalled)
    }

    func testGetProductsByCategory_WhenNoProductsExist_ShouldReturnEmptyArray() {
        // Arrange
        let mockCategory = createMockCategory(id: 1, name: "Test Category", context: context)
        mockPersistenceManager.mockProducts = nil

        // Act
        let result = sut.getProductsByCategory(mockCategory)

        // Assert
        XCTAssertTrue(result.isEmpty)
        XCTAssertTrue(mockPersistenceManager.fetchProductsByCategoryCalled)
    }

    // MARK: - getFavoriteProducts Tests

    func testGetFavoriteProducts_WhenShowFavoritesOnlyAndCategoryIsFavorite_ShouldReturnOnlyFavoriteProducts() async {
        // Arrange
        let mockCategory = createMockCategory(id: 1, name: "Test Category", context: context)
        mockCategory.favorite = true

        let mockProducts = createMockProducts(count: 3, context: context)
        mockProducts[0].favorite = true
        mockProducts[1].favorite = false
        mockProducts[2].favorite = true

        mockPersistenceManager.mockProducts = mockProducts

        // Act
        let result = await sut.getFavoriteProducts(for: mockCategory, inCase: true)

        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.favorite })
    }

    func testGetFavoriteProducts_WhenShowFavoritesOnlyFalse_ShouldReturnAllProducts() async {
        // Arrange
        let mockCategory = createMockCategory(id: 1, name: "Test Category", context: context)
        let mockProducts = createMockProducts(count: 3, context: context)
        mockPersistenceManager.mockProducts = mockProducts

        // Act
        let result = await sut.getFavoriteProducts(for: mockCategory, inCase: false)

        // Assert
        XCTAssertEqual(result.count, 3)
    }

    func testGetFavoriteProducts_WhenCategoryNotFavoriteAndShowFavoritesOnly_ShouldReturnEmptyArray() async {
        // Arrange
        let mockCategory = createMockCategory(id: 1, name: "Test Category", context: context)
        mockCategory.favorite = false

        // Act
        let result = await sut.getFavoriteProducts(for: mockCategory, inCase: true)

        // Assert
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - saveProduct Tests

    func testSaveProduct_ShouldCallSuperSaveNewProductAndRefreshData() {
        // Arrange
        mockPersistenceManager.mockNextProductId = 123
        mockPersistenceManager.shouldCreateProduct = true
        mockPersistenceManager.shouldSavePersistence = true
        mockPersistenceManager.mockProducts = []
        mockPersistenceManager.mockCategories = []

        // Act
        let result = sut.saveProduct(
            name: "Test Product",
            description: "Test Description",
            categoryId: 1,
            active: true,
            favorite: false
        )

        // Assert
        XCTAssertEqual(result, 123)
        XCTAssertTrue(mockPersistenceManager.createProductCalled)
        XCTAssertTrue(mockPersistenceManager.savePersistenceCalled)
        XCTAssertEqual(mockPersistenceManager.lastCreatedProductName, "Test Product")
    }

    // MARK: - duplicate Tests

    func testDuplicate_ShouldDeselectOriginalAndCreateCopy() {
        // Arrange
        let originalProduct = createMockProduct(id: 1, name: "Original Product", context: context)
        originalProduct.selected = true
        originalProduct.notes = "Test notes"
        originalProduct.categoryId = 5
        originalProduct.active = true
        originalProduct.favorite = true

        mockPersistenceManager.mockNextProductId = 456
        mockPersistenceManager.shouldCreateProduct = true
        mockPersistenceManager.shouldSavePersistence = true

        // Act
        let result = sut.duplicate(product: originalProduct)

        // Assert
        XCTAssertEqual(result, 456)
        XCTAssertFalse(originalProduct.selected)
        XCTAssertTrue(mockPersistenceManager.createProductCalled)
        XCTAssertEqual(mockPersistenceManager.lastCreatedProductName, "Original Product")
        XCTAssertEqual(mockPersistenceManager.lastCreatedProductNotes, "Test notes")
        XCTAssertEqual(mockPersistenceManager.lastCreatedProductCategoryId, 5)
        XCTAssertTrue(mockPersistenceManager.lastCreatedProductActive!)
        XCTAssertTrue(mockPersistenceManager.lastCreatedProductFavorite!)
    }

    // MARK: - getProductById Tests

    func testGetProductById_WhenProductExists_ShouldReturnProduct() {
        // Arrange
        let mockProducts = createMockProducts(count: 3, context: context)
        mockProducts[1].id = 42
        sut.products = mockProducts

        // Act
        let result = sut.getProductById(42)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 42)
    }

    func testGetProductById_WhenProductDoesNotExist_ShouldReturnNil() {
        // Arrange
        let mockProducts = createMockProducts(count: 3, context: context)
        sut.products = mockProducts

        // Act
        let result = sut.getProductById(999)

        // Assert
        XCTAssertNil(result)
    }

    // MARK: - setSelectedProduct Tests

    func testSetSelectedProduct_ShouldSelectProductAndDeselectOthers() {
        // Arrange
        let mockProducts = createMockProducts(count: 3, context: context)
        mockProducts[0].id = 1
        mockProducts[1].id = 2
        mockProducts[2].id = 3
        sut.products = mockProducts

        let productToSelect = mockProducts[1]

        // Act
        sut.setSelectedProduct(productToSelect)

        // Assert
        XCTAssertFalse(sut.products[0].selected)
        XCTAssertTrue(sut.products[1].selected)
        XCTAssertFalse(sut.products[2].selected)
        XCTAssertEqual(sut.selectedProduct?.id, 2)
    }

    // MARK: - addProductToList Tests

    func testAddProductToList_WhenListSelectedAndCreationSuccessful_ShouldReturnTrue() {
        // Arrange
        let mockProduct = createMockProduct(id: 1, name: "Test Product", context: context)
        mockProduct.notes = "Test notes"
        mockProduct.favorite = true

        let mockList = createMockList(name: "Test List", context: context)
        sut.selectedList = mockList

        mockPersistenceManager.shouldCreateItem = true
        mockPersistenceManager.shouldSavePersistence = true

        // Act
        let result = sut.addProductToList(mockProduct)

        // Assert
        XCTAssertTrue(result)
        XCTAssertTrue(mockPersistenceManager.createItemCalled)
        XCTAssertTrue(mockPersistenceManager.savePersistenceCalled)
        XCTAssertEqual(mockPersistenceManager.lastCreatedItemName, "Test Product")
        XCTAssertEqual(mockPersistenceManager.lastCreatedItemDescription, "Test notes")
        XCTAssertTrue(mockPersistenceManager.lastCreatedItemFavorite!)
        XCTAssertEqual(mockPersistenceManager.lastCreatedItemListId, mockList.id)
    }

    func testAddProductToList_WhenNoListSelected_ShouldReturnFalse() {
        // Arrange
        let mockProduct = createMockProduct(id: 1, name: "Test Product", context: context)
        sut.selectedList = nil
        mockPersistenceManager.mockSelectedList = nil

        // Act
        let result = sut.addProductToList(mockProduct)

        // Assert
        XCTAssertFalse(result)
        XCTAssertFalse(mockPersistenceManager.createItemCalled)
    }

    func testAddProductToList_WhenCreationFails_ShouldReturnFalse() {
        // Arrange
        let mockProduct = createMockProduct(id: 1, name: "Test Product", context: context)
        let mockList = createMockList(name: "Test List", context: context)
        sut.selectedList = mockList

        mockPersistenceManager.shouldCreateItem = false

        // Act
        let result = sut.addProductToList(mockProduct)

        // Assert
        XCTAssertFalse(result)
        XCTAssertTrue(mockPersistenceManager.createItemCalled)
        XCTAssertFalse(mockPersistenceManager.savePersistenceCalled)
    }

    // MARK: - scrollToFoundProduct Tests

    func testScrollToFoundProduct_WhenProductAndCategoryExist_ShouldExpandCategoryAndSelectProduct() {
        // Arrange
        let mockProxy = MockScrollViewProxy()
        let mockProduct = createMockProduct(id: 42, name: "Target Product", context: context)
        let mockCategory = createMockCategory(id: 1, name: "Target Category", context: context)
        let otherCategory = createMockCategory(id: 2, name: "Other Category", context: context)

        sut.products = [mockProduct]
        sut.categories = [mockCategory, otherCategory]
        mockPersistenceManager.mockCategory = mockCategory
        mockPersistenceManager.shouldSavePersistence = true

        let expectation = XCTestExpectation(description: "Scroll should be called")
        mockProxy.scrollToExpectation = expectation

        // Act
        sut.scrollToFoundProduct(proxy: mockProxy, name: "Target Product")

        // Wait for async dispatch
        wait(for: [expectation], timeout: 2.0)

        // Assert
        XCTAssertTrue(mockCategory.expanded)
        XCTAssertFalse(otherCategory.expanded)
        XCTAssertEqual(sut.selectedProduct?.id, 42)
        XCTAssertTrue(mockProxy.scrollToCalled)
        XCTAssertEqual(mockProxy.lastScrolledId as? Int16, 42)
    }

    func testScrollToFoundProduct_WhenProductNotFound_ShouldNotScroll() {
        // Arrange
        let mockProxy = MockScrollViewProxy()
        sut.products = []

        // Act
        sut.scrollToFoundProduct(proxy: mockProxy, name: "Non-existent Product")

        // Assert
        XCTAssertFalse(mockProxy.scrollToCalled)
    }

    // MARK: - confirmListSelected Tests

    func testConfirmListSelected_WhenListAlreadySelected_ShouldReturnTrue() {
        // Arrange
        let mockList = createMockList(name: "Test List", context: context)
        sut.selectedList = mockList

        // Act
        let result = sut.confirmListSelected()

        // Assert
        XCTAssertTrue(result)
    }

    func testConfirmListSelected_WhenNoListSelectedButCanFetchOne_ShouldReturnTrue() {
        // Arrange
        let mockList = createMockList(name: "Test List", context: context)
        sut.selectedList = nil
        mockPersistenceManager.mockSelectedList = mockList

        // Act
        let result = sut.confirmListSelected()

        // Assert
        XCTAssertTrue(result)
        XCTAssertEqual(sut.selectedList?.id, mockList.id)
        XCTAssertTrue(mockPersistenceManager.fetchSelectedListCalled)
    }

    // MARK: - Helper Methods

    private func createMockCategories(count: Int, context: NSManagedObjectContext) -> [DMCategory] {
        return (0..<count).map { index in
            createMockCategory(id: Int16(index), name: "Category \(index)", context: context)
        }
    }

    private func createMockCategory(id: Int16, name: String, context: NSManagedObjectContext) -> DMCategory {
        let category = DMCategory(context: context)
        category.id = id
        category.name = name
        category.favorite = false
        category.expanded = false
        return category
    }

    private func createMockProducts(count: Int, context: NSManagedObjectContext) -> [DMProduct] {
        return (0..<count).map { index in
            createMockProduct(id: Int16(index), name: "Product \(index)", context: context)
        }
    }

    private func createMockProduct(id: Int16, name: String, context: NSManagedObjectContext) -> DMProduct {
        let product = DMProduct(context: context)
        product.uuid = UUID()
        product.id = id
        product.name = name
        product.notes = "Notes \(id)"
        product.categoryId = 1
        product.active = true
        product.favorite = false
        product.custom = true
        product.selected = false
        return product
    }

    private func createMockList(name: String, context: NSManagedObjectContext) -> DMList {
        let list = DMList(context: context)
        list.id = UUID()
        list.name = name
        list.notes = "Description"
        list.creationDate = Date()
        list.pinned = false
        list.selected = false
        list.expanded = false
        list.completed = false
        return list
    }
}
