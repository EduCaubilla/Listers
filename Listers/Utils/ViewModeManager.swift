//
//  ViewModeManager.swift
//  Listers
//
//  Created by Edu Caubilla on 3/7/25.
//

import SwiftUI

struct ViewModeManager {
    static let shared = ViewModeManager()

    public func resolveViewMode(for viewMode: String) -> ColorScheme? {
        switch viewMode {
            case "Light":
                print("Resolve ViewMode light")
                return .light
            case "Dark":
                print("Resolve ViewMode dark")
                return .dark
            case "Automatic", "None":
                print("Resolve ViewMode nil")
                return nil
            default :
                print("Resolve ViewMode nil")
                return nil
        }
    }
}
