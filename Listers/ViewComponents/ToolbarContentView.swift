//
//  ToolbarContentView.swift
//  Listers
//
//  Created by Edu Caubilla on 3/7/25.
//

import SwiftUI

@ToolbarContentBuilder
func toolbarContentView(router: NavigationRouter, route: NavRoute) -> some ToolbarContent {
    ToolbarItemGroup(placement: .topBarLeading) {
        // TODO - Add search in categories
        if route != .categories {
            Button(action: {
                router.navigateTo(.categories)
            }) {
                Image("custom.list.bullet.clipboard.badge.magnifyingglass")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.darkBlue)
            }
        }

        if route != .settings {
            Button(action: {
                withTransaction(Transaction(animation: .default)) {
                    router.navigateTo(.settings)
                }
            }) {
                Image(systemName: "gearshape")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.darkBlue)
            }
        }
    }

    ToolbarItemGroup(placement: .topBarTrailing) {
        if route != .lists {
            Button(action: {
                withTransaction(Transaction(animation: .default)) {
                    router.navigateTo(.lists)
                }
            }) {
                Image("custom.checklist.square.stack")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.darkBlue)
            }
        }

        if route != .main {
            Button(action: {
                withTransaction(Transaction(animation: .default)) {
                    router.navigateTo(.main)
                }
            }) {
                Image("custom.checklist.square")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.darkBlue)
            }
        }
    }
}
