//
//  ProductAlertTypeEnum.swift
//  Listers
//
//  Created by Edu Caubilla on 15/7/25.
//

import SwiftUI

struct ProductAlertManager:Identifiable, Equatable {
    var id: UUID = UUID()
    var type: ProductAlertType

    enum ProductAlertType: String {
        case addedToList
        case edited
        case confirmRemove

        var title: String {
            switch self {
                case .addedToList:
                    return NSLocalizedString("product_alert_added", comment: "Product added to list.")
                case .edited:
                    return NSLocalizedString("product_alert_edited", comment: "Product edited.")
                case .confirmRemove:
                    return NSLocalizedString("product_alert_confirm", comment: "Confirm removal of product.")
            }
        }
    }
}

