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
    @Published var isListDeadlineEnable: Bool = false

    //MARK: - INITIALIZER
    init(persistenceManager: any PersistenceManagerProtocol = PersistenceManager.shared) {
        self.persistenceManager = persistenceManager
    }

    //MARK: - FUNCTIONS
    func loadSettingsData() {
        if let fetchedSettings = persistenceManager.fetchSettings() {
            isItemDescriptionEnable = fetchedSettings.itemDescription
            isItemQuantityEnable = fetchedSettings.itemQuantity
            isItemDeadlineEnable = fetchedSettings.itemDeadline

            isListDescriptionEnable = fetchedSettings.listDescription
            isListDeadlineEnable = fetchedSettings.listDeadline
        }
    }

    func updateSettingsData() {
        let updatedSettings = persistenceManager.updateSettings(
            itemDescription: isItemDescriptionEnable,
            itemQuantity: isItemQuantityEnable,
            itemDeadline: isItemDeadlineEnable,
            listDescription: isListDescriptionEnable,
            listDeadline: isListDeadlineEnable
        )
        if updatedSettings {
            print("Settings updated successfully")
        } else {
            print("There was an error updating the settings")
        }
    }
}
