//
//  NavigationRouter.swift
//  Listers
//
//  Created by Edu Caubilla on 2/7/25.
//

import SwiftUI

enum NavRoute: Hashable {
    case main
    case lists
    case settings
    case categories
}


class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()

    func navigateTo(_ route: NavRoute, withBack: Bool = false) {
        withTransaction(Transaction(animation: .default)) {
            if !withBack {
                path = NavigationPath()
            }
            path.append(route)
        }
    }
}
