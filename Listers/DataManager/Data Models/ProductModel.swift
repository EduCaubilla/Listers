//
//  ProductModel.swift
//  Listers
//
//  Created by Edu Caubilla on 8/7/25.
//

import SwiftUI

public struct ProductModel: Codable{
    let id: Int16
    let name: String
    let note: String?
    let categoryId: Int16
    let favorite: Bool
    let active: Bool
}
