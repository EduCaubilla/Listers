//
//  ListDTO.swift
//  Listers
//
//  Created by Edu Caubilla on 28/8/25.
//

import SwiftUI

struct ListDTO: Codable {
    let id: UUID
    let name: String
    let items: [ItemDTO]
    let notes: String?
    let creationDate: Date
    let endDate: Date?
    let selected: Bool
}
