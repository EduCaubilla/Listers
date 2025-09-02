//
//  ProductDTO.swift
//  Listers
//
//  Created by Edu Caubilla on 8/7/25.
//

import SwiftUI

struct ProductDTO: Codable{
    let id: Int16
    let name: String
    let notes: String?
    let categoryId: Int16
    let favorite: Bool
    let active: Bool
}
