import XCTest
import CoreData
@testable import Listers

final class SettingsManagerTests: XCTestCase {

    var sut: SettingsManager!
    var mockPersistenceManager: MockPersistenceManager!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPersistenceManager = MockPersistenceManager()
        // We inject the mock persistence manager to control the behavior of the SUT
        sut = SettingsManager(persistenceManager: mockPersistenceManager)
        
        // We still need a real context for creating mock data
        let mockPersistence = MockPersistence()
        context = mockPersistence.makeInMemoryPersistentContainer().viewContext
    }

    override func tearDownWithError() throws {
        sut = nil
        mockPersistenceManager = nil
        context = nil
        try super.tearDownWithError()
    }

    // MARK: - Load Settings Tests

    func testLoadSettings_whenSettingsExist_shouldLoadThemIntoCurrentSettings() {
        // Arrange
        // 1. Create a mock settings object and configure the mock manager to return it
        let settings = DMSettings(context: context)
        settings.itemDescription = false
        settings.itemQuantity = false
        mockPersistenceManager.mockSettings = settings

        // Act
        sut.loadSettings()

        // Assert
        // 2. Verify that the persistence manager was asked to fetch settings
        XCTAssertTrue(mockPersistenceManager.fetchSettingsCalled, "fetchSettings() should be called.")
        
        // 3. Verify that the manager's currentSettings property was updated
        XCTAssertNotNil(sut.currentSettings, "currentSettings should not be nil after loading.")
        XCTAssertEqual(sut.currentSettings?.itemDescription, false, "Loaded settings should have the correct value.")
        XCTAssertEqual(sut.currentSettings?.itemQuantity, false, "Loaded settings should have the correct value.")
    }

//    func testLoadSettings_whenNoSettingsExist_shouldCreateDefaultSettings() {
//        // Arrange
//        // 1. Configure the mock manager to return no settings
//        mockPersistenceManager.mockSettings = nil
//        mockPersistenceManager.shouldCreateSettings = true
//
//        // Act
//        sut.loadSettings()
//
//        // Assert
//        // 2. Verify that the manager tried to fetch settings first
//        XCTAssertTrue(mockPersistenceManager.fetchSettingsCalled, "fetchSettings() should be called.")
//        
//        // 3. Verify that the manager then tried to create the default settings
//        XCTAssertTrue(mockPersistenceManager.createSettingsCalled, "createSettings() should be called when no settings exist.")
//        
//        // 4. Verify that the correct default values were passed
//        XCTAssertTrue(mockPersistenceManager.lastCreatedSettingsItemDescription!, "Default settings should have itemDescription as true.")
//        XCTAssertTrue(mockPersistenceManager.lastCreatedSettingsItemQuantity!, "Default settings should have itemQuantity as true.")
//        XCTAssertTrue(mockPersistenceManager.lastCreatedSettingsItemEndDate!, "Default settings should have itemEndDate as true.")
//        XCTAssertTrue(mockPersistenceManager.lastCreatedSettingsListDescription!, "Default settings should have listDescription as true.")
//        XCTAssertTrue(mockPersistenceManager.lastCreatedSettingsListEndDate!, "Default settings should have listEndDate as true.")
//    }

    // MARK: - Update Settings Tests

    func testUpdateSettings_shouldCallPersistenceManagerWithCorrectValues() {
        // Arrange
        let newItemDescription = false
        let newItemQuantity = true
        let newItemEndDate = false
        let newListDescription = true
        let newListEndDate = false

        // Act
        sut.updateSettings(
            itemDescription: newItemDescription,
            itemQuantity: newItemQuantity,
            itemEndDate: newItemEndDate,
            listDescription: newListDescription,
            listEndDate: newListEndDate
        )

        // Assert
        // 1. Verify that the update function on the persistence manager was called
        XCTAssertTrue(mockPersistenceManager.updateSettingsCalled, "updateSettings() should be called.")
        
        // 2. Verify that the correct new values were passed to the persistence manager
        XCTAssertEqual(mockPersistenceManager.lastUpdatedSettingsItemDescription, newItemDescription)
        XCTAssertEqual(mockPersistenceManager.lastUpdatedSettingsItemQuantity, newItemQuantity)
        XCTAssertEqual(mockPersistenceManager.lastUpdatedSettingsItemEndDate, newItemEndDate)
        XCTAssertEqual(mockPersistenceManager.lastUpdatedSettingsListDescription, newListDescription)
        XCTAssertEqual(mockPersistenceManager.lastUpdatedSettingsListEndDate, newListEndDate)
    }
}
