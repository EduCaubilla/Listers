//
//  ProductAlertTypeEnum.swift
//  Listers
//
//  Created by Edu Caubilla on 15/7/25.
//

import SwiftUI

struct ProductAlert:Identifiable, Equatable {
    var id: UUID = UUID()
    var type: ProductAlertType

    enum ProductAlertType: String {
        case addedToList
        case addedToSelectedList
        case edited
        case confirmRemove

        var title: String {
            switch self {
                case .addedToList:
                    return "Added to List"
                case .addedToSelectedList:
                    return "Added to Selected List"
                case .edited:
                    return "Edited"
                case .confirmRemove:
                    return "Confirm Remove"
            }
        }
    }
}

