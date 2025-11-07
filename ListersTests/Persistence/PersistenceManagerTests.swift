import XCTest
import CoreData
@testable import Listers

final class PersistenceManagerTests: XCTestCase {

    var sut: PersistenceManager!
    var container: NSPersistentContainer!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // 1. Initialize an in-memory Core Data container
        container = PersistenceController(inMemory: true).container
        context = container.viewContext
        
        // 2. Initialize the SUT with the in-memory context
        sut = PersistenceManager(context: context)
    }

    override func tearDownWithError() throws {
        sut = nil
        container = nil
        context = nil
        try super.tearDownWithError()
    }

    // MARK: - List Tests

    func testCreateList_shouldSaveOneListToContext() {
        // Act
        let created = sut.createList(name: "Test List", description: "", creationDate: Date(), endDate: nil, pinned: false, selected: false, expanded: false, completed: false)

        // Assert
        XCTAssertTrue(created, "createList should return true on success.")
        
        let fetchRequest: NSFetchRequest<DMList> = DMList.fetchRequest()
        do {
            let lists = try context.fetch(fetchRequest)
            XCTAssertEqual(lists.count, 1, "There should be exactly one list in the context.")
            XCTAssertEqual(lists.first?.name, "Test List", "The list should have the correct name.")
        } catch {
            XCTFail("Fetching lists from context should not fail.")
        }
    }

    func testFetchAllLists_whenMultipleListsExist_shouldReturnAll() throws {
        // Arrange
        // Manually create two lists directly in the context
        _ = sut.createList(name: "List 1", description: "", creationDate: Date(), endDate: nil, pinned: false, selected: false, expanded: false, completed: false)
        _ = sut.createList(name: "List 2", description: "", creationDate: Date(), endDate: nil, pinned: false, selected: false, expanded: false, completed: false)

        // Act
        let fetchedLists = sut.fetchAllLists()

        // Assert
        XCTAssertNotNil(fetchedLists, "fetchAllLists should return an array, not nil.")
        XCTAssertEqual(fetchedLists?.count, 2, "fetchAllLists should return all lists that were created.")
    }

    // MARK: - Item Tests

    func testCreateItem_shouldSaveItemAndAssociateWithList() throws {
        // Arrange
        // 1. Create a list to associate the item with
        let list = DMList(context: context)
        let listId = UUID()
        list.id = listId
        list.name = "My List"
        list.notes = "My List Description"
        list.creationDate = Date()
        list.pinned = false
        list.selected = false
        list.expanded = false
        list.completed = false
        try context.save()

        // Act
        let created = sut.createItem(name: "Test Item", description: "", quantity: 1, favorite: false, priority: .normal, completed: false, selected: false, creationDate: Date.now, endDate: Date.now.addingTimeInterval(36000), image: nil, link: nil, listId: listId)

        // Assert
        XCTAssertTrue(created, "createItem should return true on success.")
        
        // 2. Fetch the list and verify its items relationship
        let fetchedList = sut.fetchList(listId)
        XCTAssertNotNil(fetchedList, "The parent list should be fetchable.")

        let fetchedItem = sut.fetchItemsForList(withId: listId)?.first
        XCTAssertNotNil(fetchedItem, "The list should now have one item.")

        // 3. Verify the item itself was created correctly
        XCTAssertEqual(fetchedItem?.name, "Test Item")
    }

    // MARK: - Generic Tests

    func testRemove_shouldDeleteObjectFromContext() throws {
        // Arrange
        // 1. Create and save a list
        _ = sut.createList(name: "To Be Deleted", description: "", creationDate: Date(), endDate: nil, pinned: false, selected: false, expanded: false, completed: false)
        
        // 2. Fetch it to make sure it exists and to get a reference to it
        guard let listToDelete = sut.fetchAllLists()?.first else {
            XCTFail("Precondition failed: Could not fetch the list to be deleted.")
            return
        }
        XCTAssertEqual(sut.fetchAllLists()?.count, 1)

        // Act
        let removed = sut.remove(listToDelete)

        // Assert
        XCTAssertTrue(removed, "remove() should return true on success.")
        XCTAssertEqual(sut.fetchAllLists()?.count, 0, "The number of lists should be 0 after deletion.")
    }

    // MARK: - Product Tests

    func testCreateProduct_shouldSaveProductToContext() {
        // Act
        let previousProducts = sut.fetchAllProducts()!
        let created = sut.createProduct(id: 1000, name: "Test Product", notes: "Notes", categoryId: 1, active: true, favorite: false, custom: true, selected: false)

        // Assert
        XCTAssertTrue(created, "createProduct should return true on success.")

        let newProducts = sut.fetchAllProducts()!
        XCTAssertEqual(newProducts.count, previousProducts.count + 1, "There should be exactly one product in the context.")

        let productFetched = sut .fetchProductById(1000)!
        XCTAssertEqual(productFetched.name, "Test Product")
    }

    func testFetchAllProducts_shouldReturnAllCreatedProducts() throws {
        // Arrange
        let initialCount = sut.fetchAllProducts()?.count ?? 0
        _ = sut.createProduct(id: 1001, name: "Product A", notes: "", categoryId: 10, active: true, favorite: false, custom: true, selected: false)
        _ = sut.createProduct(id: 1002, name: "Product B", notes: "", categoryId: 10, active: true, favorite: false, custom: true, selected: false)

        // Act
        let currentFetchedProducts = sut.fetchAllProducts()

        // Assert
        XCTAssertNotNil(currentFetchedProducts)
        XCTAssertEqual(currentFetchedProducts?.count, initialCount + 2, "The total number of products should be the initial count plus 2.")
    }

//    func testFetchNextProductId_whenProductsExist_shouldReturnHighestIdPlusOne() {
//        // Arrange
//        _ = sut.createProduct(id: 1, name: "Product A", notes: nil, categoryId: 1, active: true, favorite: false, custom: true, selected: false)
//        _ = sut.createProduct(id: 5, name: "Product B", notes: nil, categoryId: 1, active: true, favorite: false, custom: true, selected: false)
//        _ = sut.createProduct(id: 3, name: "Product C", notes: nil, categoryId: 1, active: true, favorite: false, custom: true, selected: false)
//        
//        // Act
//        let nextId = sut.fetchNextProductId()
//        
//        // Assert
//        XCTAssertEqual(nextId, 6, "The next ID should be the highest existing ID + 1.")
//    }

//    func testFetchProductById_whenProductExists_shouldReturnCorrectProduct() {
//        // Arrange
//        _ = sut.createProduct(id: 10, name: "Target Product", notes: nil, categoryId: 1, active: true, favorite: false, custom: true, selected: false)
//        _ = sut.createProduct(id: 11, name: "Other Product", notes: nil, categoryId: 1, active: true, favorite: false, custom: true, selected: false)
//
//        // Act
//        let foundProduct = sut.fetchProductById(10)
//
//        // Assert
//        XCTAssertNotNil(foundProduct)
//        XCTAssertEqual(foundProduct?.name, "Target Product")
//    }

    func testFetchProductById_whenProductDoesNotExist_shouldReturnNil() {
        // Act
        let foundProduct = sut.fetchProductById(999)

        // Assert
        XCTAssertNil(foundProduct, "Should return nil when no product with the given ID exists.")
    }
}
