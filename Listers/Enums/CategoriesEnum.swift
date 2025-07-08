//
//  CategoriesEnum.swift
//  Listers
//
//  Created by Edu Caubilla on 8/7/25.
//

import SwiftUI

enum Categories: String, CaseIterable, Identifiable {
    case Grocery
    case Beverages
    case FruitsAndVegetables
    case HomeAndKitchen
    case HardwareAndTools
    case OfficeAndStationery
    case ClothesAndFootwear
    case SportsAndOutdoors
    case HealthAndBeauty
    case Other

    var displayName: String {
        rawValue
            .replacingOccurrences(of: "And", with: " And ")
    }

    var id: String { self.rawValue }

    var categoryId: Int { numericID }

    var numericID: Int {
        switch self {
            case .Grocery:
                return 1
            case .Beverages:
                return 2
            case .FruitsAndVegetables:
                return 3
            case .HomeAndKitchen:
                return 4
            case .HardwareAndTools:
                return 5
            case .OfficeAndStationery:
                return 6
            case .ClothesAndFootwear:
                return 7
            case .SportsAndOutdoors:
                return 8
            case .HealthAndBeauty:
                return 9
            case .Other:
                return 10
        }
    }

    static func idMapper(for id: Int16) -> Categories {
        return Categories.allCases.first { $0.categoryId == Int(id) } ?? .Other
    }
}
