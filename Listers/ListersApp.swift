//
//  ListersApp.swift
//  Listers
//
//  Created by Edu Caubilla on 12/6/25.
//

import SwiftUI

@main
struct ListersApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
