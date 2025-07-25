//
//  LocalizationManger.swift
//  Listers
//
//  Created by Edu Caubilla on 25/7/25.
//

import SwiftUI

class L10n : ObservableObject {
    static var shared = L10n()

    @Published var currentLanguage: AppLanguage = .english {
        didSet {
            updateBundle()
        }
    }

    private(set) var bundle: Bundle = .main

    private init() {
        updateBundle()
    }

    private func updateBundle() {
        persistLanguage()
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            self.bundle = .main
            return
        }
        self.bundle = bundle
        objectWillChange.send() // Force update
    }

    func localize(_ key: String, comment: String = "", args: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: comment)
        return String(format: format, arguments: args)
    }
}

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

extension L10n {
    func loadLanguage() {
        if let stored = UserDefaults.standard.string(forKey: "selected_language"),
           let language = AppLanguage(rawValue: stored) {
            currentLanguage = language
        }
    }

    func persistLanguage() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selected_language")
    }
}
