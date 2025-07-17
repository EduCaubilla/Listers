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

    var settingsTitle: String = "Settings"

    var currentVisibility : Visibility {
        colorScheme == .dark ? .hidden : .visible
    }

    //MARK: - INITIALIZER
    init(vm: SettingsViewModel = SettingsViewModel()) {
        _vm = StateObject(wrappedValue: vm)
    }

    //MARK: - FUNCTIONS

    //MARK: - BODY
    var body: some View {
        VStack {
            Form {
                Section("General Settings".capitalized) {
                    Picker("View Mode", selection: $selectedAppearance) {
                        ForEach(AppAppearance.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .padding(.vertical, -5)
                }
                .padding(.vertical,3)
                .listRowBackground(colorScheme == .dark ? Color.accentColor.opacity(0.3) : Color.background)

                Section("Item Settings".capitalized) {
                    Toggle("Show Description", isOn: $vm.isItemDescriptionEnable)
                        .padding(.vertical, -5)
                    Toggle("Show Quantity", isOn: $vm.isItemQuantityEnable)
                        .padding(.vertical, -5)
                    Toggle("Show Deadline", isOn: $vm.isItemDeadlineEnable)
                        .padding(.vertical, -5)
                }
                .padding(.vertical,3)
                .listRowBackground(colorScheme == .dark ? Color.accentColor.opacity(0.3) : Color.background)

                Section("List Settings".capitalized) {
                    Toggle("Show Description", isOn: $vm.isListDescriptionEnable)
                        .padding(.vertical, -5)
                    Toggle("Show Deadline", isOn: $vm.islistEndDateEnable)
                        .padding(.vertical, -5)
                }
                .padding(.vertical,3)
                .listRowBackground(colorScheme == .dark ? Color.accentColor.opacity(0.3) : Color.background)
            }
            .formStyle(.grouped)
            .navigationTitle(Text(settingsTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.background, for: .navigationBar)
            .scrollContentBackground(currentVisibility)
            .background(Color.clear)
            .onAppear{
                vm.loadSettingsData()
            }
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
