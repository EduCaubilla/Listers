import XCTest
import CoreData
@testable import Listers

final class SettingsViewModelTests: XCTestCase {

    var sut: SettingsViewModel!
    var mockSettingsManager: MockSettingsManager!
    var context: NSManagedObjectContext! // For creating mock DMSettings

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockSettingsManager = MockSettingsManager()
        
        // We need a context to create a DMSettings object for the mock
        let mockPersistence = MockPersistence()
        context = mockPersistence.makeInMemoryPersistentContainer().viewContext
    }

    override func tearDownWithError() throws {
        sut = nil
        mockSettingsManager = nil
        context = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization and Loading Tests

    func testInit_whenSettingsExist_shouldLoadSettingsIntoPublishedProperties() {
        // Arrange
        // 1. Create a settings object with specific values
        let settings = DMSettings(context: context)
        settings.itemDescription = false
        settings.itemQuantity = false
        settings.itemEndDate = true
        settings.listDescription = true
        settings.listEndDate = false
        
        // 2. Configure the mock manager to return these settings
        mockSettingsManager.mockSettings = settings

        // Act
        // 3. Initialize the ViewModel, which automatically loads data
        sut = SettingsViewModel(settingsManager: mockSettingsManager)

        // Assert
        // 4. Verify the ViewModel's properties match the mock data
        XCTAssertEqual(sut.isItemDescriptionEnable, false)
        XCTAssertEqual(sut.isItemQuantityEnable, false)
        XCTAssertEqual(sut.isItemDeadlineEnable, true)
        XCTAssertEqual(sut.isListDescriptionEnable, true)
        XCTAssertEqual(sut.islistEndDateEnable, false)
    }

    func testInit_whenNoSettingsExist_shouldUseDefaultPublishedValues() {
        // Arrange
        // 1. Ensure no settings are returned by the manager
        mockSettingsManager.mockSettings = nil

        // Act
        // 2. Initialize the ViewModel
        sut = SettingsViewModel(settingsManager: mockSettingsManager)

        // Assert
        // 3. Verify the ViewModel's properties have their default values
        XCTAssertTrue(sut.isItemDescriptionEnable)
        XCTAssertTrue(sut.isItemQuantityEnable)
        XCTAssertFalse(sut.isItemDeadlineEnable)
        XCTAssertFalse(sut.isListDescriptionEnable)
        XCTAssertFalse(sut.islistEndDateEnable)
    }

    // MARK: - Update Tests

    func testUpdateSettingsData_shouldCallUpdateOnManagerWithCurrentValues() {
        // Arrange
        // 1. Initialize the ViewModel
        sut = SettingsViewModel(settingsManager: mockSettingsManager)
        
        // 2. Change the ViewModel's properties as a user would
        sut.isItemDescriptionEnable = false
        sut.isItemQuantityEnable = true
        sut.isItemDeadlineEnable = false
        sut.isListDescriptionEnable = true
        sut.islistEndDateEnable = false

        // Act
        sut.updateSettingsData()

        // Assert
        // 3. Verify the update function on the manager was called
        XCTAssertTrue(mockSettingsManager.updateSettingsCalled, "updateSettingsData() should trigger a call on the manager.")
        
        // 4. Verify the correct values were passed to the manager
        XCTAssertEqual(mockSettingsManager.lastUpdatedItemDescription, false)
        XCTAssertEqual(mockSettingsManager.lastUpdatedItemQuantity, true)
        XCTAssertEqual(mockSettingsManager.lastUpdatedItemEndDate, false)
        XCTAssertEqual(mockSettingsManager.lastUpdatedListDescription, true)
        XCTAssertEqual(mockSettingsManager.lastUpdatedListEndDate, false)
    }
}
