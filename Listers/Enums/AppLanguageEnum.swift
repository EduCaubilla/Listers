//
//  AppLanguageEnum.swift
//  Listers
//
//  Created by Edu Caubilla on 28/7/25.
//

import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"

    var displayName: String {
        switch self {
            case .english: return "English"
            case .spanish: return "Español"
        }
    }

    var id: String { self.rawValue }

    var localizedDisplayName: String {
        NSLocalizedString(displayName, comment: "")
    }

    static var allLocalizedCases: [String] {
        AppLanguage.allCases.map { $0.localizedDisplayName }
    }
}
