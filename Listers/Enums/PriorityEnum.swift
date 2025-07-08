//
//  Priority.swift
//  Listers
//
//  Created by Edu Caubilla on 13/6/25.
//

import Foundation

enum Priority: String {
    case normal = "Normal"
    case high = "High"
    case veryHigh = "Very High"

    static var allCases: [String] {
        ["Normal", "High", "Very High"]
    }
}
