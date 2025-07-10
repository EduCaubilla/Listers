//
//  SettingsView.swift
//  Listers
//
//  Created by Edu Caubilla on 25/6/25.
//

import SwiftUI

struct SettingsView: View {
    //MARK: - PROPERTIES
    @AppStorage("selectedViewMode") private var selectedViewMode: SettingsViewMode = .automatic

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var router: NavigationRouter

    @State private var isItemDateEnable: Bool = false
    @State private var isItemCategoryEnable: Bool = false
    @State private var isItemDescriptionEnable: Bool = false

    @State private var isListDateEnable: Bool = false
    @State private var isListCategoryEnable: Bool = false
    @State private var isListDescriptionEnable: Bool = false

    private var viewMode: SettingsViewMode {
        get { selectedViewMode }
        set { selectedViewMode = newValue }
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
                        ForEach(SettingsViewMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
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
//            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color.background, for: .navigationBar)
//            .toolbar {
//                toolbarContentView(router: router, route: .settings)
//            }
            .scrollContentBackground(currentVisibility)
            .background(Color.clear)
        } //: VSTACK
        .background(Color.background)
    }
}

enum SettingsViewMode : String, CaseIterable, Identifiable {
    case light
    case dark
    case automatic

    var displayName: String {
        rawValue.capitalized
    }

    var id: String { self.rawValue }
}

//MARK: - PREVIEW
#Preview {
    NavigationStack{
        SettingsView()
            .environmentObject(NavigationRouter())
    }
}
