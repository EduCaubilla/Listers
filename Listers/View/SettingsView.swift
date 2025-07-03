//
//  SettingsView.swift
//  Listers
//
//  Created by Edu Caubilla on 25/6/25.
//

import SwiftUI

struct SettingsView: View {
    //MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var router: NavigationRouter

    @State private var isDarkModeEnable: Bool = false

    @State private var isItemDateEnable: Bool = false
    @State private var isItemCategoryEnable: Bool = false
    @State private var isItemDescriptionEnable: Bool = false

    @State private var isListDateEnable: Bool = false
    @State private var isListCategoryEnable: Bool = false
    @State private var isListDescriptionEnable: Bool = false

    var viewTitle: String = "Settings"

    //MARK: - FUNCTIONS
    private func setColorScheme() {
        if colorScheme == .dark {
            UserDefaults.standard.set("dark", forKey: "theme")
        } else {
            UserDefaults.standard.set("light", forKey: "theme")
        }
    }

    //MARK: - BODY
    var body: some View {
        VStack {
            Form {
                Section("General Settings".capitalized) {
                    Toggle("Dark Mode", isOn: $isDarkModeEnable)
                }
                .padding(.vertical,3)

                Section("Item Settings".capitalized) {
                    Toggle("Show Date", isOn: $isItemDateEnable)
                    Toggle("Show Category", isOn: $isItemCategoryEnable)
                    Toggle("Show Description", isOn: $isItemDescriptionEnable)
                }
                .padding(.vertical,3)

//                Section("List Settings".capitalized) {
//                    Toggle("Show Date", isOn: $isListDateEnable)
//                    Toggle("Show Category", isOn: $isListCategoryEnable)
//                    Toggle("Show Description", isOn: $isListDescriptionEnable)
//                }
//                .padding(.vertical,3)

            }
            .formStyle(.grouped)
            .navigationTitle(Text(viewTitle))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                toolbarContentView(router: router, route: .settings)
            }
        } //: NAVIGATION
        .onAppear{
            setColorScheme()
        }
    }
}

//MARK: - PREVIEW
#Preview {
    SettingsView()
}
