//
//  SettingsView.swift
//  Listers
//
//  Created by Edu Caubilla on 25/6/25.
//

import SwiftUI

struct SettingsView: View {
    //MARK: - PROPERTIES
    @AppStorage("selectedAppearance") private var selectedAppearance: AppAppearance = .automatic

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var router: NavigationRouter

    @StateObject var vm : SettingsViewModel

    private var viewMode: AppAppearance {
        get { selectedAppearance }
        set { selectedAppearance = newValue }
    }

    @State var selectedLanguage: AppLanguage = .english

    var settingsTitle: String = L10n.shared.localize("settings_view_title")

    var currentVisibility : Visibility {
        colorScheme == .dark ? .hidden : .visible
    }

    //MARK: - INITIALIZER
    init(vm: SettingsViewModel = SettingsViewModel()) {
        _vm = StateObject(wrappedValue: vm)
    }

    //MARK: - FUNCTIONS
    private func customSettingsBinding(get: @escaping () -> Bool, set: @escaping (Bool) -> Void) -> Binding<Bool> {
        Binding(
            get: get,
            set: { newValue in
                set(newValue)
                vm.updateSettingsData()
            }
        )
    }

    //MARK: - BODY
    var body: some View {
        VStack {
            Form {
                Section(L10n.shared.localize("settings_view_general").capitalized) {
                    Picker(L10n.shared.localize("settings_view_appearance"), selection: $selectedAppearance) {
                        ForEach(AppAppearance.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .padding(.vertical, -5)

                    Picker(L10n.shared.localize("settings_view_language"), selection: $selectedLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .padding(.vertical, -5)
                }
                .padding(.vertical,3)
                .listRowBackground(colorScheme == .dark ? Color.accentColor.opacity(0.3) : Color.background)

                Section(L10n.shared.localize("settings_view_items").capitalized) {
                    Toggle(L10n.shared.localize("settings_view_description"), isOn: customSettingsBinding(
                        get: { vm.isItemDescriptionEnable },
                        set: { vm.isItemDescriptionEnable = $0}
                    ))
                        .padding(.vertical, -5)
                    Toggle(L10n.shared.localize("settings_view_quantity"), isOn: customSettingsBinding(
                        get: { vm.isItemQuantityEnable },
                        set: { vm.isItemQuantityEnable = $0 }
                    ))
                        .padding(.vertical, -5)
                    Toggle(L10n.shared.localize("settings_view_end_date"), isOn: customSettingsBinding(
                        get: { vm.isItemDeadlineEnable },
                        set: { vm.isItemDeadlineEnable = $0 }
                    ))
                        .padding(.vertical, -5)
                }
                .padding(.vertical,3)
                .listRowBackground(colorScheme == .dark ? Color.accentColor.opacity(0.3) : Color.background)

                Section(L10n.shared.localize("settings_view_lists").capitalized) {
                    Toggle(L10n.shared.localize("settings_view_description"), isOn: customSettingsBinding(
                        get: { vm.isListDescriptionEnable },
                        set: { vm.isListDescriptionEnable = $0 }
                    ))
                        .padding(.vertical, -5)
                    Toggle(L10n.shared.localize("settings_view_end_date"), isOn: customSettingsBinding(
                        get: { vm.islistEndDateEnable },
                        set: { vm.islistEndDateEnable = $0 }
                    ))
                        .padding(.vertical, -5)
                }
                .padding(.vertical,3)
                .listRowBackground(colorScheme == .dark ? Color.accentColor.opacity(0.3) : Color.background)
            }
            .formStyle(.grouped)
            .navigationTitle(Text(settingsTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContentView(router: router, route: .settings)
            } //: TOOLBAR
            .toolbarBackground(Color.background, for: .navigationBar)
            .scrollContentBackground(currentVisibility)
            .background(Color.clear)
            .onDisappear {
                vm.updateSettingsData()
            }
        } //: VSTACK
        .background(Color.background)
    }
}


//MARK: - PREVIEW
#Preview {
    NavigationStack{
        SettingsView(vm: SettingsViewModel())
            .environmentObject(NavigationRouter())
    }
}
