//
//  SettingsManager.swift
//  Listers
//
//  Created by Edu Caubilla on 17/7/25.
//

import SwiftUI
import CoreData

class SettingsManager {
    //MARK: - PROPERTIES
    private let persistenceManager : any PersistenceManagerProtocol

    static let shared = SettingsManager()

    //MARK: - INITIALIZER
    init(persistenceManager: any PersistenceManagerProtocol = PersistenceManager.shared) {
        self.persistenceManager = persistenceManager
    }

    //MARK: - FUNCTIONS
    func loadSettings() {
        if persistenceManager.fetchSettings() == nil {
            let newSettings = persistenceManager.createSettings(
                itemDeadline: false,
                itemDescription: true,
                itemQuantity: true,
                listDeadline: false,
                listDescription: true
            )

            if newSettings {
                print("Default settings created")
            } else {
                print("There was an error creating default settings")
            }
        }
    }
}
