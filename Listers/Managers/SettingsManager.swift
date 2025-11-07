//
//  SettingsManager.swift
//  Listers
//
//  Created by Edu Caubilla on 17/7/25.
//

import SwiftUI
import CoreData
import CocoaLumberjackSwift

class SettingsManager: SettingsManagerProtocol {
    //MARK: - PROPERTIES
    private let persistenceManager : any PersistenceManagerProtocol

    static let shared = SettingsManager()

    private(set) var currentSettings : DMSettings?

    //MARK: - INITIALIZER
    init(persistenceManager: any PersistenceManagerProtocol = PersistenceManager.shared) {
        self.persistenceManager = persistenceManager
    }

    //MARK: - FUNCTIONS
    func loadSettings() {
        if let existingSettings = persistenceManager.fetchSettings() {
            self.currentSettings = existingSettings
        } else {
            let newDefaultSettings = persistenceManager.createSettings(
                itemDescription: true,
                itemQuantity: true,
                itemEndDate: true,
                listDescription: true,
                listEndDate: true
            )

            if newDefaultSettings {
                reloadSettings()
                DDLogInfo("SettingsManager: Default settings created")
            } else {
                DDLogError("SettingsManager: There was an error creating default settings")
            }
        }
    }

    func reloadSettings() {
        if currentSettings == nil {
            if let existingSettings = persistenceManager.fetchSettings() {
                self.currentSettings = existingSettings
            } else {
                loadSettings()
            }
        }
    }

    func updateSettings(itemDescription: Bool, itemQuantity: Bool, itemEndDate: Bool, listDescription: Bool, listEndDate: Bool) {
        let updatedSettings = persistenceManager.updateSettings(
            itemDescription: itemDescription,
            itemQuantity: itemQuantity,
            itemEndDate: itemEndDate,
            listDescription: listDescription,
            listEndDate: listEndDate
        )

        if let newSettings = persistenceManager.fetchSettings(), updatedSettings  {
            self.currentSettings = newSettings
        } else {
            DDLogError("SettingsManager: There was an error updating the settings")
        }
    }
}
