//
//  ViewModeManager.swift
//  Listers
//
//  Created by Edu Caubilla on 3/7/25.
//

import SwiftUI
import CocoaLumberjackSwift

struct AppAppearanceManager {
    static let shared = AppAppearanceManager()

    public func resolveAppearance(for appearance: String) -> ColorScheme? {
        switch appearance.capitalized {
            case "Light":
                DDLogInfo("AppAppearanceManager: Resolve Appearance light")
                return .light
            case "Dark":
                DDLogInfo("AppAppearanceManager: Resolve Appearance dark")
                return .dark
            case "Automatic", "None":
                DDLogInfo("AppAppearanceManager: Resolve Appearance nil")
                return nil
            default :
                DDLogInfo("AppAppearanceManager: Resolve Appearance nil")
                return nil
        }
    }
}
