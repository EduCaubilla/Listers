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
    let persistenceController = PersistenceController.shared

    //MARK: - BODY
    var body: some Scene {
        WindowGroup {
            RootView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: handleEnterForeround)
        }
    }

    //MARK: - FUNCTIONS
    func handleEnterForeround(_ note: Notification) {
        persistenceController.saveContext()
    }
}
