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

    var localizedDisplayName: String {
        switch self {
            case .Grocery:
                return NSLocalizedString("category_groceries", comment: "Category Groceries")
            case .Beverages:
                return NSLocalizedString("category_beverages", comment: "Category Beverages")
            case .FruitsAndVegetables:
                return NSLocalizedString("category_fruits_and_vegetables", comment: "Category Fruits and Vegetables")
            case .HomeAndKitchen:
                return NSLocalizedString("category_home_and_kitchen", comment: "Home and Kitchen")
            case .HardwareAndTools:
                return NSLocalizedString("category_hardware_and_tools", comment: "Hardware and Tools")
            case .OfficeAndStationery:
                return NSLocalizedString("category_office_and_stationery", comment: "Office and Stationery")
            case .ClothesAndFootwear:
                return NSLocalizedString("category_clothes_and_footwear", comment: "Clothes and Footwear")
            case .SportsAndOutdoors:
                return NSLocalizedString("category_sports_and_oudoors", comment: "Sports and Oudoors")
            case .HealthAndBeauty:
                return NSLocalizedString("category_health_and_beauty", comment: "Health and Beauty")
            case .Other:
                return NSLocalizedString("category_other", comment: "Category Other")
        }
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
