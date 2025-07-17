//
//  ViewModeManager.swift
//  Listers
//
//  Created by Edu Caubilla on 3/7/25.
//

import SwiftUI

struct AppAppearanceManager {
    static let shared = AppAppearanceManager()

    public func resolveAppearance(for appearance: String) -> ColorScheme? {
        switch appearance {
            case "Light":
                print("Resolve Appearance light")
                return .light
            case "Dark":
                print("Resolve Appearance dark")
                return .dark
            case "Automatic", "None":
                print("Resolve Appearance nil")
                return nil
            default :
                print("Resolve Appearance nil")
                return nil
        }
    }
}
