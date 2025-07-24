//
//  RootView.swift
//  Listers
//
//  Created by Edu Caubilla on 2/7/25.
//

import SwiftUI

struct RootView: View {
    //MARK: - PROPERTIES
    @StateObject var router = NavigationRouter()
    @StateObject var vm = MainItemsListsViewModel()

    //MARK: - BODY
    var body: some View {
        NavigationStack (path: $router.path) {
            MainItemsView(vm: vm)
                .environmentObject(router)
                .navigationDestination(for: NavRoute.self) { route in
                    switch route {
                        case .main:
                            MainItemsView(vm: vm)
                                .environmentObject(router)
                        case .lists:
                            ListsView(vm: vm)
                                .environmentObject(router)
                        case .settings:
                            SettingsView()
                                .environmentObject(router)
                        case .categories:
                            CategoriesProductsView()
                                .environmentObject(router)
                    }
                } //: NAV DESTINATION
        } //: NAV STACK
    } //: VIEW
}
