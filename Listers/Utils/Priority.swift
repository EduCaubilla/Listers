//
//  Priority.swift
//  Listers
//
//  Created by Edu Caubilla on 13/6/25.
//

import Foundation

enum Priority: String {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    static var allCases: [String] {
        ["Low", "Medium", "High"]
    }
}
