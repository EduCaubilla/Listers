//
//  DataManager.swift
//  Listers
//
//  Created by Edu Caubilla on 8/7/25.
//

import SwiftUI
import CoreData

class DataManager {
    //MARK: - PROPERTIES
    static let shared = DataManager()

    let localizationManager = L10n.shared

    private init() {}

    //MARK: - LOAD CATEGORIES + PRODUCTS DATA
    func loadInitialDataIfNeeded<T: NSManagedObject & JSONLoadable>(for entityType: T.Type, context: NSManagedObjectContext) {
        let languageChanged = localizationManager.checkChangedLanguage()

        let requestCurrentData = NSFetchRequest<T>(entityName: T.entityName)
        requestCurrentData.fetchLimit = 1

        do {
            let count = try context.count(for: requestCurrentData)

            // When there's data and language hasn't changed then return
            if count > 0 && !languageChanged {
                print("Table \(T.entityName) already has data, skipping initial load.")
                return
            }

            // When language changed we delete data and load new
            if languageChanged {
                print("Table \(T.entityName) needs to load as language was changed.")
                loadDataFromJSON(for: entityType, context: context, cleanLoad: true)
            }

            // When there's no data we just load new
            if count == 0 {
                print("Table \(T.entityName) is empty, loading initial data.")
                loadDataFromJSON(for: entityType, context: context)
            }
        } catch {
            print("Error checking table for \(T.entityName): \(error.localizedDescription)")
        }
    }

    func loadDataFromJSON<T: NSManagedObject & JSONLoadable>(for entityType: T.Type, context: NSManagedObjectContext, cleanLoad: Bool = false) {
        if cleanLoad {
            deleteEntityTable(named: entityType.entityName, using: context)
        }

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

    func deleteEntityTable(named entityName: String, using context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            let results = try context.fetch(fetchRequest) as? [NSManagedObject]
            results?.forEach { context.delete($0) }
        } catch {
            print("Error fetching for entity \(entityName): \(error)")
        }

        do {
            try context.save()
        } catch {
            print("Error saving after deleting entity tables: \(error)")
        }
    }

    //MARK: - LIST SHARING
    func exportList(_ list: DMList) -> URL? {
        let listData = list.toModel()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]

        do {
            let data = try encoder.encode(listData)
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(UUID()).json")
            try data.write(to: url)
            return url
        } catch {
            print("Export List Data Error: \(error)")
            return nil
        }
    }

    func importList(from url: URL, context: NSManagedObjectContext) {
        do {
            guard let data = try? Data(contentsOf: url) else {
                print("JSON file import list in \(url) could not be read.")
                return
            }

            let listData = try JSONDecoder().decode(ListModel.self, from: data)
            _ = DMList.mapper(from: listData, context: context)

            try context.save()
        } catch {
            print("Import List Data Error: \(error)")
        }
    }
}
