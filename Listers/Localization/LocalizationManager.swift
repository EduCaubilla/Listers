//
//  LocalizationManger.swift
//  Listers
//
//  Created by Edu Caubilla on 25/7/25.
//

import SwiftUI

class L10n : ObservableObject {
    //MARK: - PROPERTIES
    static var shared = L10n()

    //MARK: - INITIALIZER
    private init() {
    }

    //MARK: - FUNCTIONS
    func localize(_ key: String, comment: String = "", args: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: comment)
        return String(format: format, arguments: args)
    }
}

extension L10n {
    func getSavedLanguage() -> String {
        var responseLanguage: String = ""
        if let storedLanguage = UserDefaults.standard.string(forKey: "selected_language") {
            responseLanguage = storedLanguage
        }
        return responseLanguage
    }

    func getSystemLanguage() -> String {
        return Locale.current.language.languageCode?.identifier ?? ""
    }

    func persistLanguage(_ language: AppLanguage) {
        UserDefaults.standard.set(language.rawValue, forKey: "selected_language")
    }

    func persistLanguage() {
        if let languageCode = Locale.current.language.languageCode?.identifier,
           let languageSelected = AppLanguage(rawValue: languageCode) {
            persistLanguage(languageSelected)
        }
    }

    func checkChangedLanguage() -> Bool {
        //Check if language has changed
        let savedlanguage = getSavedLanguage()
        let systemLanguage = getSystemLanguage()

        var languageChanged = false
        if !savedlanguage.isEmpty && !systemLanguage.isEmpty {
            languageChanged = savedlanguage != systemLanguage
        }
        return languageChanged
    }
}
