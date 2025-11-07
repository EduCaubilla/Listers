import Foundation
import CoreData
@testable import Listers

class MockSettingsManager: SettingsManagerProtocol {
    
    // MARK: - Properties for Mocking
    
    // We can configure this property in our tests to simulate settings being present or not
    var mockSettings: DMSettings?
    var currentSettings: DMSettings? {
        return mockSettings
    }
    
    // MARK: - Properties for Tracking Calls
    
    private(set) var loadSettingsCalled = false
    private(set) var updateSettingsCalled = false
    
    // Track the values passed to the update function
    private(set) var lastUpdatedItemDescription: Bool?
    private(set) var lastUpdatedItemQuantity: Bool?
    private(set) var lastUpdatedItemEndDate: Bool?
    private(set) var lastUpdatedListDescription: Bool?
    private(set) var lastUpdatedListEndDate: Bool?
    
    // MARK: - Protocol Conformance
    
    func loadSettings() {
        loadSettingsCalled = true
        // In a real scenario, this would load from persistence.
        // For the mock, we just use what's in `mockSettings`.
    }
    
    func updateSettings(itemDescription: Bool, itemQuantity: Bool, itemEndDate: Bool, listDescription: Bool, listEndDate: Bool) {
        updateSettingsCalled = true
        
        // Record the values that were passed
        lastUpdatedItemDescription = itemDescription
        lastUpdatedItemQuantity = itemQuantity
        lastUpdatedItemEndDate = itemEndDate
        lastUpdatedListDescription = listDescription
        lastUpdatedListEndDate = listEndDate
    }
}
