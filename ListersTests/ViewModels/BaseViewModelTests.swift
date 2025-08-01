//
//  BaseViewModel.swift
//  ListersTests
//
//  Created by Edu Caubilla on 29/7/25.
//

import XCTest
import CoreData
import SwiftUI
@testable import Listers

final class BaseViewModelTests: XCTestCase {

    var sut: BaseViewModel!
    var mockPersistenceManager: MockPersistenceManager!
    var mockPersistence: MockPersistence!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPersistenceManager = MockPersistenceManager()
        mockPersistence = MockPersistence()
        context = mockPersistence.makeInMemoryPersistentContainer().viewContext
        sut = BaseViewModel(persistenceManager: mockPersistenceManager)
    }

    override func tearDownWithError() throws {
        mockPersistenceManager = nil
        mockPersistence = nil
        context = nil
        sut = nil

        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testInit_ShouldSetPersistenceManager() {
        // Arrange & Act
        let viewModel = BaseViewModel(persistenceManager: mockPersistenceManager)

        // Assert
        XCTAssertTrue(viewModel.persistenceManager is MockPersistenceManager)
    }

    func testInit_ShouldInitializePropertiesWithDefaultValues() {
        // Arrange & Act & Assert
        XCTAssertNil(sut.selectedList)
        XCTAssertTrue(sut.products.isEmpty)
        XCTAssertTrue(sut.productNames.isEmpty)
        XCTAssertNil(sut.activeAlert)
        XCTAssertFalse(sut.showingAddItemView)
        XCTAssertFalse(sut.showingUpdateItemView)
        XCTAssertFalse(sut.showingAddListView)
        XCTAssertFalse(sut.showingUpdateListView)
        XCTAssertFalse(sut.showingAddProductView)
        XCTAssertFalse(sut.showingUpdateProductView)
        XCTAssertFalse(sut.showingListToAddProductView)
    }

    // MARK: - fetchProducts Tests

    func testFetchProducts_WhenProductsExist_ShouldUpdateProductsAndLoadNames() {
        // Arrange
        let mockProducts: [DMProduct] = createMockProducts(count: 3, context: context)
        mockPersistenceManager.mockProducts = mockProducts

        // Expectation for async update
        let expectation = XCTestExpectation(description: "Product names should be loaded")

        // Act
        sut.fetchProducts()

        // Wait for async dispatch to complete
        DispatchQueue.main.async {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        // Assert
        XCTAssertEqual(sut.products.count, 3)
        XCTAssertTrue(mockPersistenceManager.fetchAllActiveProductsCalled)
        XCTAssertEqual(sut.productNames.count, 3)
        XCTAssertEqual(sut.productNames, ["Product 0", "Product 1", "Product 2"])
    }

    // MARK: - loadProductNames Tests

    func testLoadProductNames_WhenProductNamesEmpty_ShouldLoadFromProducts() {
        // Arrange
        let mockProducts = createMockProducts(count: 2, context: context)
        sut.products = mockProducts

        // Expectation for async update
        let expectation = XCTestExpectation(description: "Product names should be loaded")

        // Act
        sut.loadProductNames()

        // Wait for async dispatch to complete
        DispatchQueue.main.async {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        // Assert
        XCTAssertEqual(sut.productNames.count, 2)
        XCTAssertEqual(sut.productNames, ["Product 0", "Product 1"])
    }

    func testLoadProductNames_WhenProductNamesExistAndForceLoadFalse_ShouldNotReload() {
        // Arrange
        sut.productNames = ["Existing Product"]
        let mockProducts = createMockProducts(count: 2, context: context)
        sut.products = mockProducts

        // Act
        sut.loadProductNames(forceLoad: false)

        // Assert
        XCTAssertEqual(sut.productNames.count, 1)
        XCTAssertEqual(sut.productNames, ["Existing Product"])
    }

    func testLoadProductNames_WhenForceLoadTrue_ShouldReloadProductNames() {
        // Arrange
        sut.productNames = ["Existing Product"]
        let mockProducts = createMockProducts(count: 2, context: context)
        sut.products = mockProducts

        let expectation = XCTestExpectation(description: "Product names loaded")

        // Act
        sut.loadProductNames(forceLoad: true)

        // Wait for async dispatch to complete
        DispatchQueue.main.async {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)

        // Assert
        XCTAssertEqual(sut.productNames.count, 2)
        XCTAssertEqual(sut.productNames, ["Product 0", "Product 1"])
    }

    func testLoadProductNames_WhenProductsEmptyAndPersistenceHasProducts_ShouldFetchAndLoad() {
        // Arrange
        let mockProducts = createMockProducts(count: 2, context: context)
        mockPersistenceManager.mockProducts = mockProducts
        XCTAssertTrue(sut.products.isEmpty)

        // Act
        sut.loadProductNames()

        // Assert
        XCTAssertTrue(mockPersistenceManager.fetchAllActiveProductsCalled)
        XCTAssertEqual(sut.products.count, 2)
    }

    // MARK: - saveNewProduct Tests

    func testSaveNewProduct_WhenSuccessful_ShouldReturnProductId() {
        // Arrange
        let expectedId = 123
        mockPersistenceManager.mockNextProductId = expectedId
        mockPersistenceManager.shouldCreateProduct = true
        var refreshCalled = false

        // Act
        let result = sut.saveNewProduct(
            name: "Test Product",
            description: "Test Description",
            categoryId: 1,
            active: true,
            favorite: false
        ) {
            refreshCalled = true
        }

        // Assert
        XCTAssertEqual(result, expectedId)
        XCTAssertTrue(mockPersistenceManager.createProductCalled)
        XCTAssertTrue(refreshCalled)
        XCTAssertEqual(mockPersistenceManager.lastCreatedProductName, "Test Product")
        XCTAssertEqual(mockPersistenceManager.lastCreatedProductNotes, "Test Description")
        XCTAssertEqual(mockPersistenceManager.lastCreatedProductCategoryId, 1)
        XCTAssertTrue(mockPersistenceManager.lastCreatedProductActive!)
        XCTAssertFalse(mockPersistenceManager.lastCreatedProductFavorite!)
    }

    func testSaveNewProduct_WhenFailed_ShouldReturnMinusOne() {
        // Arrange
        let expectedId = 123
        mockPersistenceManager.mockNextProductId = expectedId
        mockPersistenceManager.shouldCreateProduct = false
        var refreshCalled = false

        // Act
        let result = sut.saveNewProduct(
            name: "Test Product",
            description: nil,
            categoryId: 1,
            active: true,
            favorite: false
        ) {
            refreshCalled = true
        }

        // Assert
        XCTAssertEqual(result, -1)
        XCTAssertTrue(mockPersistenceManager.createProductCalled)
        XCTAssertFalse(refreshCalled)
    }

    func testSaveNewProduct_WithNilDescription_ShouldUseEmptyString() {
        // Arrange
        mockPersistenceManager.mockNextProductId = 123
        mockPersistenceManager.shouldCreateProduct = true

        // Act
        _ = sut.saveNewProduct(
            name: "Test Product",
            description: nil,
            categoryId: 1,
            active: true,
            favorite: false
        ) { }

        // Assert
        XCTAssertEqual(mockPersistenceManager.lastCreatedProductNotes, "")
    }

    // MARK: - createIdForNewProduct Tests

    func testCreateIdForNewProduct_ShouldReturnNextProductId() {
        // Arrange
        let expectedId = 456
        mockPersistenceManager.mockNextProductId = expectedId

        // Act
        let result = sut.createIdForNewProduct()

        // Assert
        XCTAssertEqual(result, expectedId)
        XCTAssertTrue(mockPersistenceManager.fetchNextProductIdCalled)
    }

    // MARK: - saveChanges Tests

    func testSaveChanges_WhenSuccessful_ShouldCallRefresh() {
        // Arrange
        mockPersistenceManager.shouldSavePersistence = true
        var refreshCalled = false

        // Act
        sut.saveChanges {
            refreshCalled = true
        }

        // Assert
        XCTAssertTrue(mockPersistenceManager.savePersistenceCalled)
        XCTAssertTrue(refreshCalled)
    }

    func testSaveChanges_WhenFailed_ShouldNotCallRefresh() {
        // Arrange
        mockPersistenceManager.shouldSavePersistence = false
        var refreshCalled = false

        // Act
        sut.saveChanges {
            refreshCalled = true
        }

        // Assert
        XCTAssertTrue(mockPersistenceManager.savePersistenceCalled)
        XCTAssertFalse(refreshCalled)
    }

    // MARK: - delete Tests

    func testDelete_WhenSuccessful_ShouldCallRefresh() {
        // Arrange
        let mockObject = MockManagedObject()
        mockPersistenceManager.shouldRemoveObject = true
        var refreshCalled = false

        // Act
        sut.delete(mockObject) {
            refreshCalled = true
        }

        // Assert
        XCTAssertTrue(mockPersistenceManager.removeCalled)
        XCTAssertTrue(refreshCalled)
    }

    func testDelete_WhenFailed_ShouldNotCallRefresh() {
        // Arrange
        let mockObject = MockManagedObject()
        mockPersistenceManager.shouldRemoveObject = false
        var refreshCalled = false

        // Act
        sut.delete(mockObject) {
            refreshCalled = true
        }

        // Assert
        XCTAssertTrue(mockPersistenceManager.removeCalled)
        XCTAssertFalse(refreshCalled)
    }

    func testDelete_WithoutRefreshClosure_ShouldNotCrash() {
        // Arrange
        let mockObject = MockManagedObject()
        mockPersistenceManager.shouldRemoveObject = true

        // Act & Assert (should not crash)
        sut.delete(mockObject)

        XCTAssertTrue(mockPersistenceManager.removeCalled)
    }

    // MARK: - Helper Method

    private func createMockProducts(count: Int, context: NSManagedObjectContext) -> [DMProduct] {
        var productList: [DMProduct] = []

        productList = (0..<count).map { index in
            let product = DMProduct(context: context)
            product.id = Int16(index)
            product.uuid = UUID()
            product.name = "Product \(index)"
            product.notes = "Notes for Product \(index)"
            product.categoryId = Int16(0)
            product.active = true
            product.favorite = false
            product.selected = false
            product.custom = false
            return product
        }
        return productList
    }
}
