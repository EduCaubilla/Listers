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
}


class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()

    func navigateTo(_ route: NavRoute) {
        path = NavigationPath()
        path.append(route)
    }
}
