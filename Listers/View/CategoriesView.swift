//
//  CategoriesView.swift
//  Listers
//
//  Created by Edu Caubilla on 4/7/25.
//

import SwiftUI

struct CategoriesView: View {
    //MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var router: NavigationRouter

    var categoriesList : [DMCategory] = []
    var productsList : [DMItem] = []

    @State var showingAddCategoryProductView: Bool = false

    var categoriesTitle : String = "Categories"
    var addItemLabel: String = "Add Item"
    var addItemIcon: String = "plus"

    var currentVisibility : Visibility {
        colorScheme == .dark ? .hidden : .visible
    }

    //MARK: - FUNCTIONS

    //MARK: - BODY
    var body: some View {
        VStack{
            Form {
                Section("General Settings".capitalized) {

                }
                .padding(.vertical,3)
                .listRowBackground(colorScheme == .dark ? Color.accentColor.opacity(0.3) : Color.background)
            }
            .formStyle(.grouped)
            .navigationTitle(Text(categoriesTitle))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .safeAreaInset(
                edge: .bottom,
                content: {
                    MainAddButtonView(
                        addButtonLabel: addItemLabel,
                        addButtonIcon: addItemIcon,
                        addButtonAction: {showingAddCategoryProductView.toggle()}
                    )
                })
            .toolbarBackground(Color.background, for: .navigationBar)
            .toolbar {
                toolbarContentView(router: router, route: .categories)
            }
            .scrollContentBackground(currentVisibility)
            .background(Color.clear)
        } //: VSTACK MAIN
        .sheet(isPresented: $showingAddCategoryProductView) {
            AddUpdateCategoryProductView()
                .padding(.top, 20)
                .presentationDetents([.height(260)])
                .presentationBackground(Color.background)
        }
        .background(Color.background)
    } //: VIEW
}

//MARK: - PREVIEW
#Preview {
    CategoriesView()
        .environmentObject(NavigationRouter())
}
