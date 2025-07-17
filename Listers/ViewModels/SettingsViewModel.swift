//
//  SettingsViewModel.swift
//  Listers
//
//  Created by Edu Caubilla on 17/7/25.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    //MARK: - PROPERTIES
    private let persistenceManager : any PersistenceManagerProtocol
    static let shared = SettingsViewModel()

    @Published var isItemDescriptionEnable: Bool = true
    @Published var isItemQuantityEnable: Bool = true
    @Published var isItemDeadlineEnable: Bool = false

    @Published var isListDescriptionEnable: Bool = false
    @Published var islistEndDateEnable: Bool = false

    //MARK: - INITIALIZER
    init(persistenceManager: any PersistenceManagerProtocol = PersistenceManager.shared) {
        self.persistenceManager = persistenceManager
    }

    //MARK: - FUNCTIONS
    func loadSettingsData() {
        if let fetchedSettings = persistenceManager.fetchSettings() {
            isItemDescriptionEnable = fetchedSettings.itemDescription
            isItemQuantityEnable = fetchedSettings.itemQuantity
            isItemDeadlineEnable = fetchedSettings.itemEndDate

            isListDescriptionEnable = fetchedSettings.listDescription
            islistEndDateEnable = fetchedSettings.listEndDate
        }
        print("Settings loaded successfully")
    }

    func updateSettingsData() {
        let updatedSettings = persistenceManager.updateSettings(
            itemDescription: isItemDescriptionEnable,
            itemQuantity: isItemQuantityEnable,
            itemEndDate: isItemDeadlineEnable,
            listDescription: isListDescriptionEnable,
            listEndDate: islistEndDateEnable
        )
        if updatedSettings {
            print("Settings updated successfully")
        } else {
            print("There was an error updating the settings")
        }
    }
}
