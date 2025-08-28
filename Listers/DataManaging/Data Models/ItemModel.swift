//
//  ItemModel.swift
//  Listers
//
//  Created by Edu Caubilla on 28/8/25.
//

import SwiftUI

struct ItemModel: Codable {
    let id: UUID
    let listId: UUID
    let name: String
    let notes: String?
    let priority: String?
    let quantity: Int?
    let creationDate: Date?
    let endDate: Date?
}
