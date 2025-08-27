//
//  MainItemsListViewModelTests.swift
//  ListersTests
//
//  Created by Edu Caubilla on 29/7/25.
//

import XCTest
import CoreData
import SwiftUI
import Combine
@testable import Listers

final class MainItemsListViewModelTests: XCTestCase {

    var sut: MainItemsListsViewModel!
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

        sut = MainItemsListsViewModel(persistenceManager: mockPersistenceManager)
    }

    override func tearDownWithError() throws {
        cancellables?.removeAll()
        mockPersistenceManager = nil
        mockPersistence = nil
        context = nil
        sut = nil

        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testInit_ShouldSetPersistenceManager() {
        // Arrange & Act
        let viewModel = MainItemsListsViewModel(persistenceManager: mockPersistenceManager)

        // Assert
        XCTAssertTrue(viewModel.persistenceManager is MockPersistenceManager)
    }

    func testInit_ShouldInitializePropertiesWithDefaultValues() {
        // Arrange & Act & Assert
        XCTAssertTrue(sut.itemsOfSelectedList.isEmpty)
        XCTAssertTrue(sut.lists.isEmpty)
        XCTAssertFalse(sut.showSaveNewProductAlert)
        XCTAssertFalse(sut.showCompletedListAlert)
        XCTAssertEqual(sut.currentScreen, .main)
    }

    // MARK: - Computed Properties Tests

    func testIsListsEmpty_WhenListsEmpty_ShouldReturnTrue() {
        // Arrange
        sut.lists = []

        // Act & Assert
        XCTAssertTrue(sut.isListsEmpty)
    }

    func testIsListsEmpty_WhenListsNotEmpty_ShouldReturnFalse() {
        // Arrange
        let mockLists = createMockLists(count: 2, context: context)
        sut.lists = mockLists

        // Act & Assert
        XCTAssertFalse(sut.isListsEmpty)
    }

    func testHasSelectedList_WhenSelectedListExists_ShouldReturnTrue() {
        // Arrange
        let mockList = createMockList(name: "Test List", context: context)
        sut.selectedList = mockList

        // Act & Assert
        XCTAssertTrue(sut.hasSelectedList)
    }

    func testHasSelectedList_WhenNoSelectedList_ShouldReturnFalse() {
        // Arrange
        sut.selectedList = nil

        // Act & Assert
        XCTAssertFalse(sut.hasSelectedList)
    }

    func testSelectedListName_WhenSelectedListExists_ShouldReturnName() {
        // Arrange
        let mockList = createMockList(name: "Test List", context: context)
        sut.selectedList = mockList

        // Act & Assert
        XCTAssertEqual(sut.selectedListName, "Test List")
    }

    func testSelectedListName_WhenNoSelectedList_ShouldReturnEmptyString() {
        // Arrange
        sut.selectedList = nil

        // Act & Assert
        XCTAssertEqual(sut.selectedListName, "")
    }

    // MARK: - loadLists Tests

    func testLoadLists_WhenListsExist_ShouldLoadAndSortLists() async {
        // Arrange
        let mockLists = createMockLists(count: 4, context: context)
        mockLists[0].name = "Pinned List"
        mockLists[0].pinned = true
        mockLists[1].name = "Regular List B"
        mockLists[1].pinned = false
        mockLists[1].creationDate = Date.now
        mockLists[2].name = "Regular List A"
        mockLists[2].pinned = false
        mockLists[2].creationDate = Date.now
        mockLists[3].name = "List C"
        mockLists[3].pinned = false
        mockLists[3].creationDate = Date.now.addingTimeInterval(-500)

        mockPersistenceManager.mockLists = mockLists
        mockPersistenceManager.shouldSetListCompleteness = true

        // Act
        await sut.loadLists()

        // Assert
        XCTAssertEqual(sut.lists.count, 4)
        XCTAssertTrue(mockPersistenceManager.fetchAllListsCalled)
        XCTAssertTrue(mockPersistenceManager.setListCompletenessCalled)

        // Verify sorting: pinned first, then alphabetical
        XCTAssertTrue(sut.lists[0].pinned)
        XCTAssertEqual(sut.lists[0].name, "Pinned List")

        XCTAssertTrue(!sut.lists[1].pinned)
        XCTAssertEqual(sut.lists[1].name!, "List C")
    }

    func testLoadLists_WhenNoLists_ShouldSetEmptyArray() async {
        // Arrange
        mockPersistenceManager.mockLists = nil

        // Act
        await sut.loadLists()

        // Assert
        XCTAssertTrue(sut.lists.isEmpty)
        XCTAssertTrue(mockPersistenceManager.fetchAllListsCalled)
    }

    // MARK: - updateSelectedList Tests

    func testUpdateSelectedList_ShouldUpdateSelectedListAndMarkOthersUnselected() async {
        // Arrange
        let mockLists = createMockLists(count: 3, context: context)
        let newSelectedList = mockLists[1]
        sut.lists = mockLists
        mockPersistenceManager.shouldSavePersistence = true

        // Act
        await sut.updateSelectedList(newSelectedList)

        // Assert
        XCTAssertFalse(sut.lists[0].selected, "First list should not be selected")
        XCTAssertTrue(sut.lists[1].selected, "Second list should be selected")
        XCTAssertFalse(sut.lists[2].selected, "Third list should not be selected")

        XCTAssertEqual(sut.selectedList?.id, newSelectedList.id)
        XCTAssertTrue(mockPersistenceManager.savePersistenceCalled)
    }

    // MARK: - checkListCompletedStatus Tests

    func testCheckListCompletedStatus_WhenListCompleted_ShouldShowAlert() async {
        // Arrange
        let mockList = createMockList(name: "Test List", context: context)
        sut.selectedList = mockList
        sut.currentScreen = .main
        mockPersistenceManager.shouldSetListCompleteness = true

        let expectation = XCTestExpectation(description: "Alert should be shown")

        // Act
        await sut.checkListCompletedStatus()

        // Wait for the delayed alert
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)

        // Assert
        XCTAssertTrue(mockPersistenceManager.setListCompletenessCalled)
        XCTAssertTrue(sut.showCompletedListAlert)
    }

    func testCheckListCompletedStatus_WhenListNotCompleted_ShouldNotShowAlert() async {
        // Arrange
        let mockList = createMockList(name: "Test List", context: context)
        sut.selectedList = mockList
        sut.currentScreen = .main
        mockPersistenceManager.shouldSetListCompleteness = false

        // Act
        await sut.checkListCompletedStatus()

        // Assert
        XCTAssertTrue(mockPersistenceManager.setListCompletenessCalled)
        XCTAssertFalse(sut.showCompletedListAlert)
    }

    // MARK: - addList Tests

    func testAddList_WhenSuccessful_ShouldCreateListAndSaveChanges() {
        // Arrange
        mockPersistenceManager.shouldCreateList = true
        mockPersistenceManager.shouldSavePersistence = true

        // Act
        sut.addList(
            name: "New List",
            description: "Description",
            creationDate: Date(),
            endDate: nil,
            pinned: false,
            selected: false,
            expanded: false
        )

        // Assert
        XCTAssertTrue(mockPersistenceManager.createListCalled)
        XCTAssertTrue(mockPersistenceManager.savePersistenceCalled)
        XCTAssertEqual(mockPersistenceManager.lastCreatedListName, "New List")
        XCTAssertEqual(mockPersistenceManager.lastCreatedListDescription, "Description")
    }

    func testAddList_WhenFailed_ShouldNotSaveChanges() {
        // Arrange
        mockPersistenceManager.shouldCreateList = false

        // Act
        sut.addList(
            name: "New List",
            description: "Description",
            creationDate: Date(),
            endDate: nil,
            pinned: false,
            selected: false,
            expanded: false
        )

        // Assert
        XCTAssertTrue(mockPersistenceManager.createListCalled)
        XCTAssertFalse(mockPersistenceManager.savePersistenceCalled)
    }

    // MARK: - addItemToList Tests

    func testAddItemToList_WhenSuccessful_ShouldCreateItemAndSaveChanges() {
        // Arrange
        mockPersistenceManager.shouldCreateItem = true
        mockPersistenceManager.shouldSavePersistence = true
        let testDate = Date()
        let testListId = UUID()

        // Act
        sut.addItemToList(
            name: "New Item",
            description: "Item Description",
            quantity: 1,
            favorite: false,
            priority: .normal,
            completed: false,
            selected: false,
            creationDate: testDate,
            endDate: nil,
            image: nil,
            link: nil,
            listId: testListId
        )

        // Assert
        XCTAssertTrue(mockPersistenceManager.createItemCalled)
        XCTAssertTrue(mockPersistenceManager.savePersistenceCalled)
        XCTAssertEqual(mockPersistenceManager.lastCreatedItemName, "New Item")
        XCTAssertEqual(mockPersistenceManager.lastCreatedItemDescription, "Item Description")
        XCTAssertEqual(mockPersistenceManager.lastCreatedItemQuantity, 1)
        XCTAssertEqual(mockPersistenceManager.lastCreatedItemListId, testListId)
    }

    // MARK: - deleteList Tests

    func testDeleteList_ShouldDeleteItemsAndList() {
        // Arrange
        let mockList = createMockList(name: "Test List", context: context)
        let mockItems = createMockItems(count: 2, context: context)
        mockItems.forEach { $0.listId = mockList.id }

        sut.itemsOfSelectedList = mockItems
        mockPersistenceManager.mockItems = []  // No items remaining
        mockPersistenceManager.shouldRemoveObject = true

        // Act
        sut.deleteList(mockList)

        // Assert
        XCTAssertTrue(mockPersistenceManager.removeCalled)
        XCTAssertTrue(mockPersistenceManager.fetchItemsForListCalled)
    }

    // MARK: - loadItemsForSelectedList Tests

    func testLoadItemsForSelectedList_WhenSelectedListExists_ShouldLoadAndSortItems() async {
        // Arrange
        let mockList = createMockList(name: "Test List", context: context)
        let mockItems = createMockItems(count: 3, context: context)
        mockItems[0].completed = true
        mockItems[1].completed = false
        mockItems[2].completed = false

        sut.selectedList = mockList
        mockPersistenceManager.mockItems = mockItems

        // Act
        await sut.loadItemsForSelectedList()

        // Assert
        XCTAssertEqual(sut.itemsOfSelectedList.count, 3)
        XCTAssertTrue(mockPersistenceManager.fetchItemsForListCalled)

        // Verify sorting: incomplete items first
        XCTAssertFalse(sut.itemsOfSelectedList[0].completed)
        XCTAssertFalse(sut.itemsOfSelectedList[1].completed)
        XCTAssertTrue(sut.itemsOfSelectedList[2].completed)
    }

    func testLoadItemsForSelectedList_WhenNoSelectedList_ShouldNotLoadItems() async {
        // Arrange
        sut.selectedList = nil

        // Act
        await sut.loadItemsForSelectedList()

        // Assert
        XCTAssertTrue(sut.itemsOfSelectedList.isEmpty)
        XCTAssertFalse(mockPersistenceManager.fetchItemsForListCalled)
    }

    func testLoadItemsForSelectedList_WhenNoItems_ShouldLogAndReturn() async {
        // Arrange
        let mockList = createMockList(name: "Test List", context: context)
        sut.selectedList = mockList
        mockPersistenceManager.mockItems = nil

        // Act
        await sut.loadItemsForSelectedList()

        // Assert
        XCTAssertTrue(sut.itemsOfSelectedList.isEmpty)
        XCTAssertTrue(mockPersistenceManager.fetchItemsForListCalled)
    }


    // MARK: - fetchItemsForList Tests

    func testFetchItemsForList_WhenListHasId_ShouldReturnItems() {
        // Arrange
        let mockList = createMockList(name: "Test List", context: context)
        let mockItems = createMockItems(count: 2, context: context)
        mockPersistenceManager.mockItems = mockItems

        // Act
        let result = sut.fetchItemsForList(mockList)

        // Assert
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(mockPersistenceManager.fetchItemsForListCalled)
    }

    func testFetchItemsForList_WhenListHasNoId_ShouldReturnEmptyArray() {
        // Arrange
        let mockList = createMockList(name: "Test List", context: context)
        mockList.id = nil

        // Act
        let result = sut.fetchItemsForList(mockList)

        // Assert
        XCTAssertTrue(result.isEmpty)
        XCTAssertFalse(mockPersistenceManager.fetchItemsForListCalled)
    }

    // MARK: - saveProduct Tests

    func testSaveProduct_ShouldCallSuperSaveNewProduct() {
        // Arrange
        mockPersistenceManager.mockNextProductId = 123
        mockPersistenceManager.shouldCreateProduct = true
        mockPersistenceManager.shouldSavePersistence = true

        // Act
        sut.saveProduct(
            name: "Test Product",
            description: "Test Description",
            categoryId: 1,
            active: true,
            favorite: false
        )

        // Assert
        XCTAssertTrue(mockPersistenceManager.createProductCalled)
        XCTAssertTrue(mockPersistenceManager.savePersistenceCalled)
        XCTAssertEqual(mockPersistenceManager.lastCreatedProductName, "Test Product")
    }

    // MARK: - Helper Methods

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

    private func createMockLists(count: Int, context: NSManagedObjectContext) -> [DMList] {
        let resultLists = (0..<count).map { index in
            return createMockList(name: "List \(index)", context: context)
        }
        return resultLists
    }

    private func createMockItems(count: Int, context: NSManagedObjectContext) -> [DMItem] {
        return (0..<count).map { index in
            let item = DMItem(context: context)
            item.id = UUID()
            item.name = "Item \(index)"
            item.notes = "Description \(index)"
            item.quantity = Int16(index + 1)
            item.favorite = false
            item.priority = Priority.normal.rawValue
            item.completed = false
            item.creationDate = Date()
            item.endDate = Date()
            item.image = ""
            item.link = ""
            item.listId = UUID()
            return item
        }
    }

    private func createMockProducts(count: Int, context: NSManagedObjectContext) -> [DMProduct] {
        return (0..<count).map { index in
            let product = DMProduct(context: context)
            product.uuid = UUID()
            product.id = Int16(index)
            product.name = "Product \(index)"
            product.notes = "Notes \(index)"
            product.categoryId = 1
            product.active = true
            product.favorite = false
            product.custom = true
            product.selected = false
            return product
        }
    }
}
