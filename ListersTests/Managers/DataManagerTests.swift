import XCTest
import CoreData
@testable import Listers

final class DataManagerTests: XCTestCase {

    var sut: DataManager!
    var mockPersistence: MockPersistence!
    var persistenceManager: PersistenceManager!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Using a mock persistence helper to get an in-memory Core Data stack
        mockPersistence = MockPersistence()
        persistenceManager = PersistenceManager.shared
        context = mockPersistence.makeInMemoryPersistentContainer().viewContext
        sut = DataManager.shared
    }

    override func tearDownWithError() throws {
        sut = nil
        mockPersistence = nil
        context = nil
        try super.tearDownWithError()
    }

    // MARK: - Export Tests
    func testExportList_whenListIsValid_shouldReturnURLWithCorrectData() throws {
        // Arrange
        // 1. Create a mock list with items in our in-memory context
        let list = createMockList(name: "Grocery", context: context)

        let _ = createMockItem(name: "Milk", context: context, list: list)
        let _ = createMockItem(name: "Bread", context: context, list: list)

        do {
            try context.save()
        }
        catch {
            print("Failed to save context for test setup \(error.localizedDescription)")
            XCTFail("Failed to save context for test setup.")
        }

        // Act
        let exportedURL = sut.exportList(list)

        // Assert
        // 1. Check that a valid URL was returned
        XCTAssertNotNil(exportedURL, "Exporting a valid list should return a URL.")
        XCTAssertEqual(exportedURL?.lastPathComponent, "Grocery.listersjson", "The exported filename should match the list name.")

        // 2. Verify the content of the exported file
        let data = try Data(contentsOf: exportedURL!)
        let decodedList = try JSONDecoder().decode(ListDTO.self, from: data)

        XCTAssertEqual(decodedList.name, "Grocery", "The exported list name should match.")
        XCTAssertEqual(decodedList.items.count, 2, "The exported list should contain the correct number of items.")
        XCTAssertTrue(decodedList.items.contains(where: { $0.name == "Milk" }), "The exported items should include 'Milk'.")
    }

    func testExportList_whenListIsEmpty_shouldStillExportCorrectly() throws {
        // Arrange
        let list = createMockList(name: "Empty List", context: context)

        // Act
        let exportedURL = sut.exportList(list)

        // Assert
        XCTAssertNotNil(exportedURL)
        
        let data = try Data(contentsOf: exportedURL!)
        let decodedList = try JSONDecoder().decode(ListDTO.self, from: data)

        XCTAssertEqual(decodedList.name, "Empty List")
        XCTAssertEqual(decodedList.items.count, 0, "An empty list should export with 0 items.")
    }

    // MARK: - Import Tests
    func testImportList_whenDataIsValid_shouldCreateNewListAndItemsInCoreData() throws {
        // Arrange
        // 1. Create a DTO object and encode it to a temporary JSON file
        let itemDTO = ItemDTO(id: UUID(), listId: UUID(), name: "Imported Item", notes: "", priority: "normal", quantity: 1, creationDate: Date(), endDate: Date())
        let listDTO = ListDTO(id: UUID(), name: "Imported List", items: [itemDTO], notes: "", creationDate: Date(), endDate: Date(), selected: true)

        let encoder = JSONEncoder()
        let data = try encoder.encode(listDTO)
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("importTest.listersjson")
        try data.write(to: tempURL)

        // 2. Set up an expectation to wait for the async import to complete
        let expectation = XCTestExpectation(description: "Import should complete and post a notification.")
        let observer = NotificationCenter.default.addObserver(forName: NSNotification.Name("ShareListLoaded"), object: nil, queue: .main) { _ in
            expectation.fulfill()
        }

        // Act
        sut.importList(from: tempURL, context: context)

        // 3. Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: 2.0)
        NotificationCenter.default.removeObserver(observer)

        // Assert
        // 4. Fetch from the context to verify the data was actually saved
        let fetchRequest = DMList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", "Imported List")
        
        let results = try context.fetch(fetchRequest)
        
        XCTAssertEqual(results.count, 1, "A new list should have been created in Core Data.")
        XCTAssertEqual(results.first?.items?.count, 1, "The new list should have one item.")
        
        let importedItem = results.first?.items?.allObjects.first as? DMItem
        XCTAssertEqual(importedItem?.name, "Imported Item", "The item's name should match the imported data.")
    }

    func testImportList_whenJSONIsMalformed_shouldNotCreateList() throws {
        // Arrange
        // 1. Create a string with invalid JSON and write it to a temp file
        let malformedJSON = "{\"name\": \"Malformed List\", \"items\": [}" // Invalid JSON
        let data = Data(malformedJSON.utf8)
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("malformed.listersjson")
        try data.write(to: tempURL)

        // 2. Get the initial count of lists
        let fetchRequest = DMList.fetchRequest()
        let initialCount = try context.count(for: fetchRequest)

        // Act
        sut.importList(from: tempURL, context: context)
        
        // 3. We need to wait for the async Task inside importList to finish
        // Since it won't post a notification on failure, a short sleep is the simplest way.
        Task {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }

        // Assert
        // 4. Verify that no new list was created
        let finalCount = try context.count(for: fetchRequest)
        XCTAssertEqual(initialCount, finalCount, "The number of lists should not change when importing a malformed file.")
    }

    // MARK: - Helper Methods

    private func createMockList(name: String, context: NSManagedObjectContext) -> DMList {
        let list = DMList(context: context)
        list.id = UUID()
        list.name = name
        list.notes = "\(name) Note"
        list.creationDate = Date()
        list.pinned = false
        list.selected = false
        list.expanded = false
        list.completed = false
        return list
    }

    private func createMockItem(name: String, context: NSManagedObjectContext, list: DMList) -> DMItem {
        let item = DMItem(context: context)
        item.id = UUID()
        item.listId = list.id
        item.name = name
        item.notes = "\(name) Note"
        item.priority = "normal"
        item.quantity = Int16(1)
        item.creationDate = Date.now
        item.endDate = Date.now.addingTimeInterval(36000)
        item.list = list
        return item
    }

    // MARK: - Initial Data Loading Tests

    func testLoadInitialDataIfNeeded_afterInitialLoad_doesNotDuplicateData() throws {
        // Arrange
        var initialProductsCount: Int = 0
        var initialCategoriesCount: Int = 0

        let products = persistenceManager.fetchAllProducts()
        initialProductsCount = products!.count

        let categories = persistenceManager.fetchAllCategories()
        initialCategoriesCount = categories!.count

        XCTAssertGreaterThan(initialProductsCount, 0, "Precondition: Initial products should have been loaded.")
        XCTAssertGreaterThan(initialCategoriesCount, 0, "Precondition: Initial categories should have been loaded.")

        // Act
        // Call the loading function a second time
        sut.loadInitialDataIfNeeded(for: DMProduct.self, context: context)
        sut.loadInitialDataIfNeeded(for: DMCategory.self, context: context)

        // Assert
        // Verify that the counts have not changed, proving no data was duplicated
        let finalProductsCount = persistenceManager.fetchAllProducts()!.count
        let finalCategoriesCount = persistenceManager.fetchAllCategories()!.count

        XCTAssertEqual(initialProductsCount, finalProductsCount, "Product count should not change on a second load.")
        XCTAssertEqual(initialCategoriesCount, finalCategoriesCount, "Category count should not change on a second load.")
    }

    func testLoadDataFromJSON_withCleanLoad_deletesOldData() throws {
        // Arrange
        // 1. The setUp loads initial data. We add a custom product on top of it.
        let product = DMProduct(context: context)
        product.uuid = UUID()
        product.id = 9999
        product.name = "Test Product"
        product.notes = "Notes Test Product"
        product.categoryId = 1
        product.active = true
        product.favorite = false
        product.custom = true
        product.selected = false
        try context.save()

        // 2. Verify our custom product exists
        let fetchRequest: NSFetchRequest<DMProduct> = DMProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", "Test Product")
        let countBefore = try context.count(for: fetchRequest)
        XCTAssertEqual(countBefore, 1, "Precondition: The custom product should exist before clean load.")

        // Act
        // 3. Call the function with cleanLoad = true
        sut.loadDataFromJSON(for: DMProduct.self, context: context, cleanLoad: true)

        // Assert
        // 4. Verify that our custom product has been deleted
        let countAfter = try context.count(for: fetchRequest)
        XCTAssertEqual(countAfter, 0, "The custom product should be deleted after a clean load.")
    }
}
