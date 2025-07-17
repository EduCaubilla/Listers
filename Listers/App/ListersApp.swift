//
//  ListersApp.swift
//  Listers
//
//  Created by Edu Caubilla on 12/6/25.
//

import SwiftUI

@main
struct ListersApp: App {
    //MARK: - PROPERTIES
    @AppStorage("selectedAppearance") var selectedAppearance: String = AppAppearance.automatic.rawValue

    let persistenceController = PersistenceController.shared
    let appAppearanceManager = AppAppearanceManager.shared
    let settingsManager = SettingsManager.shared

    //MARK: - BODY
    var body: some Scene {
        WindowGroup {
                RootView()
                    .preferredColorScheme(appAppearanceManager.resolveAppearance(for: selectedAppearance))
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: handleEnterForeround)
                    .onAppear{
                        settingsManager.loadSettings()
                    }
        }
    }

    //MARK: - FUNCTIONS
    func handleEnterForeround(_ note: Notification) {
        persistenceController.saveContext()
    }
}
