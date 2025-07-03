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
    @AppStorage("selectedViewMode") var selectedViewMode: String = SettingsViewMode.automatic.rawValue

    let persistenceController = PersistenceController.shared
    let viewModeManager = ViewModeManager.shared

    //MARK: - BODY
    var body: some Scene {
        WindowGroup {
                RootView()
                    .preferredColorScheme(viewModeManager.resolveViewMode(for: selectedViewMode))
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: handleEnterForeround)
        }
    }

    //MARK: - FUNCTIONS
    func handleEnterForeround(_ note: Notification) {
        persistenceController.saveContext()
    }
}
