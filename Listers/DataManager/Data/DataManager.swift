//
//  DataManager.swift
//  Listers
//
//  Created by Edu Caubilla on 8/7/25.
//

import SwiftUI
import CoreData

class DataManager {
    static let shared = DataManager()

    private init() {}

    func loadInitialDataIfEmpty<T: NSManagedObject & JSONLoadable>(for entityType: T.Type, context: NSManagedObjectContext) {
        //Check if table is empty
        let request = NSFetchRequest<T>(entityName: T.entityName)
        request.fetchLimit = 1

        do {
            let count = try context.count(for: request)
            //If table is empty we load the json
            if count == 0 {
                print("Table \(T.entityName) is empty, loading initial data.")
                loadDataFromJSON(for: entityType, context: context)
            } else {
                print("Table \(T.entityName) already has data, skipping initial load.")
            }
        } catch {
            print("Error checking table for \(T.entityName): \(error.localizedDescription)")
        }
    }

    func loadDataFromJSON<T: NSManagedObject & JSONLoadable>(for entityType: T.Type, context: NSManagedObjectContext) {
        guard let url = Bundle.main.url(forResource: T.jsonFileName, withExtension: "json") else {
            print("JSON file \(T.jsonFileName).json not found.")
            return
        }
        print("JSON found : \(url)")

        guard let data = try? Data(contentsOf: url) else {
            print("JSON file in \(url) could not be read.")
            return
        }

        do {
            let jsonData = try JSONDecoder().decode([T.JSONModel].self, from: data)

            for item in jsonData {
                let _ = T.mapper(from: item, context: context)
            }

            try context.save()
            print("Succesfully loaded \(jsonData.count) items of data for \(T.entityName)")

        } catch {
            print("Error loading data from JSON: \(error.localizedDescription)")
        }
    }
}
