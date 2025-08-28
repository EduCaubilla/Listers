//
//  ListModel.swift
//  Listers
//
//  Created by Edu Caubilla on 28/8/25.
//

import SwiftUI

struct ListModel: Codable {
    let id: UUID
    let name: String
    let items: [ItemModel]
    let notes: String?
    let creationDate: Date
    let endDate: Date?
}
