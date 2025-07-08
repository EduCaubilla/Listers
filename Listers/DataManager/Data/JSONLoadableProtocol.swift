//
//  JSONLoadableProtocol.swift
//  Listers
//
//  Created by Edu Caubilla on 8/7/25.
//

import SwiftUI
import CoreData

protocol JSONLoadable {
    associatedtype JSONModel: Codable

    static func mapper(from jsonModel: JSONModel, context: NSManagedObjectContext) -> Self
    static var entityName: String { get }
    static var jsonFileName: String { get }
}
