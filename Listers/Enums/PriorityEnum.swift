//
//  Priority.swift
//  Listers
//
//  Created by Edu Caubilla on 13/6/25.
//

import Foundation

enum Priority: String, CaseIterable {
    case normal = "Normal"
    case high = "High"
    case veryHigh = "Very High"

    var localizedDisplayName: String {
        switch self {
            case .normal:
                return NSLocalizedString("priority_normal", comment: "Normal priority level for item.")
            case .high:
                return NSLocalizedString("priority_high", comment: "High priority level for item.")
            case .veryHigh:
                return NSLocalizedString("priority_very_high", comment: "Very high priority level for item.")
        }
    }

    static var allLocalizedCases: [String] {
        Priority.allCases.map { $0.localizedDisplayName }
    }
}
