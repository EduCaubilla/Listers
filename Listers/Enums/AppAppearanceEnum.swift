//
//  AppAppearanceEnum.swift
//  Listers
//
//  Created by Edu Caubilla on 17/7/25.
//

import SwiftUI

enum AppAppearance : String, CaseIterable, Identifiable {
    case light
    case dark
    case automatic

    var displayName: String {
        switch self {
            case .light:
                return L10n.shared.localize("appearance_light")
            case .dark:
                return L10n.shared.localize("appearance_dark")
            case .automatic:
                return L10n.shared.localize("appearance_automatic")
        }
    }

    var id: String { self.rawValue }
}
