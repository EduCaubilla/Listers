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
        rawValue.capitalized
    }

    var id: String { self.rawValue }
}
