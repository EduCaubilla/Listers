//
//  SettingsViewModel.swift
//  Listers
//
//  Created by Edu Caubilla on 17/7/25.
//

import SwiftUI
import Combine
import CocoaLumberjackSwift

class SettingsViewModel: ObservableObject {
    //MARK: - PROPERTIES
    private let settingsManager: SettingsManagerProtocol
    static let shared = SettingsViewModel()

    @Published var isItemDescriptionEnable: Bool = true
    @Published var isItemQuantityEnable: Bool = true
    @Published var isItemDeadlineEnable: Bool = false

    @Published var isListDescriptionEnable: Bool = false
    @Published var islistEndDateEnable: Bool = false

    //MARK: - INITIALIZER
    init(settingsManager: SettingsManagerProtocol = SettingsManager.shared) {
        self.settingsManager = settingsManager
        loadSettingsData()
    }

    //MARK: - FUNCTIONS
    func loadSettingsData() {
        if let fetchedSettings = settingsManager.currentSettings {
            isItemDescriptionEnable = fetchedSettings.itemDescription
            isItemQuantityEnable = fetchedSettings.itemQuantity
            isItemDeadlineEnable = fetchedSettings.itemEndDate

            isListDescriptionEnable = fetchedSettings.listDescription
            islistEndDateEnable = fetchedSettings.listEndDate
        }
        DDLogInfo("SettingsViewModel: Settings loaded successfully")
    }

    func updateSettingsData() {
        settingsManager.updateSettings(
            itemDescription: isItemDescriptionEnable,
            itemQuantity: isItemQuantityEnable,
            itemEndDate: isItemDeadlineEnable,
            listDescription: isListDescriptionEnable,
            listEndDate: islistEndDateEnable
        )
    }
}
