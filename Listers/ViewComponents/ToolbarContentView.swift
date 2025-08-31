//
//  ToolbarContentView.swift
//  Listers
//
//  Created by Edu Caubilla on 3/7/25.
//

import SwiftUI

/// Builds a common toolbar for some pages. Main and Lists views has all items, and settings and categories has none as they're like a navigation link.
/// - Parameters:
///   - router: Class that appends route to path
///   - route: Enum containing all views
///   - action: Closure to trigger when tap sharing
/// - Returns: A content to populate a toolbar
@ToolbarContentBuilder
func toolbarContentView(router: NavigationRouter, route: NavRoute, action: @escaping () -> Void = {}) -> some ToolbarContent {
    ToolbarItemGroup(placement: .topBarLeading) {
        if route == .main || route == .lists {
            // To Library
            Button(action: {
                withTransaction(Transaction(animation: .default)) {
                    router.navigateTo(.categories, withBack: true)
                }
            }) {
                Image("custom.list.bullet.clipboard.badge.magnifyingglass")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.darkBlue)
            }

            // To Settings
            Button(action: {
                withTransaction(Transaction(animation: .default)) {
                    router.navigateTo(.settings, withBack: true)
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
        if route == .main {
            // Share List
            Button(action: {
                action()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.darkBlue)
                    .frame(height: 26)
                    .padding(.bottom, 3)
            }

            // To Lists
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

        if route == .lists {
            // To Main List
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
