//
//  SettingsView.swift
//  Listers
//
//  Created by Edu Caubilla on 25/6/25.
//

import SwiftUI

struct SettingsView: View {
    //MARK: - PROPERTIES
    @AppStorage("selectedViewMode") private var selectedViewMode: String = SettingsViewMode.automatic.rawValue

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var router: NavigationRouter

    @State private var isItemDateEnable: Bool = false
    @State private var isItemCategoryEnable: Bool = false
    @State private var isItemDescriptionEnable: Bool = false

    @State private var isListDateEnable: Bool = false
    @State private var isListCategoryEnable: Bool = false
    @State private var isListDescriptionEnable: Bool = false

    private var viewMode: SettingsViewMode {
        get { SettingsViewMode(rawValue: selectedViewMode) ?? .automatic }
        set { selectedViewMode = newValue.rawValue }
    }

    var settingsTitle: String = "Settings"

    var currentVisibility : Visibility {
        colorScheme == .dark ? .hidden : .visible
    }

    //MARK: - FUNCTIONS

    //MARK: - BODY
    var body: some View {
        VStack {
            Form {
                Section("General Settings".capitalized) {
                    Picker("View Mode", selection: $selectedViewMode) {
                        Text("Light").tag(SettingsViewMode.light.rawValue)
                        Text("Dark").tag(SettingsViewMode.dark.rawValue)
                        Text("Automatic").tag(SettingsViewMode.automatic.rawValue)
                    }
                }
                .padding(.vertical,3)
                .listRowBackground(colorScheme == .dark ? Color.accentColor.opacity(0.3) : Color.background)

//                Section("Item Settings".capitalized) {
//                    Toggle("Show Date", isOn: $isItemDateEnable)
//                    Toggle("Show Category", isOn: $isItemCategoryEnable)
//                    Toggle("Show Description", isOn: $isItemDescriptionEnable)
//                }
//                .padding(.vertical,3)
//                .listRowBackground(colorScheme == .dark ? Color.accentColor.opacity(0.3) : Color.background)
//
//                Section("List Settings".capitalized) {
//                    Toggle("Show Date", isOn: $isListDateEnable)
//                    Toggle("Show Category", isOn: $isListCategoryEnable)
//                    Toggle("Show Description", isOn: $isListDescriptionEnable)
//                }
//                .padding(.vertical,3)
//                .listRowBackground(colorScheme == .dark ? Color.accentColor.opacity(0.3) : Color.background)

            }
            .formStyle(.grouped)
            .navigationTitle(Text(settingsTitle))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color.background, for: .navigationBar)
            .toolbar {
                toolbarContentView(router: router, route: .settings)
            }
            .scrollContentBackground(currentVisibility)
            .background(Color.clear)
        } //: VSTACK
        .background(Color.background)
    }
}

enum SettingsViewMode : String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case automatic = "Automatic"

    static var allCases: [String] {
        ["Light", "Dark", "Automatic"]
    }
}

//MARK: - PREVIEW
#Preview {
    NavigationStack{
        SettingsView()
            .environmentObject(NavigationRouter())
    }
}
