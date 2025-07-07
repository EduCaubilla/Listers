//
//  CategoriesView.swift
//  Listers
//
//  Created by Edu Caubilla on 4/7/25.
//

import SwiftUI
import CoreData

struct CategoriesProductsView: View {
    //MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var router: NavigationRouter

    @StateObject var vm : CategoriesProductsViewModel

    var categoriesTitle : String = "Categories"
    var addProductLabel: String = "Add Product"
    var addIcon: String = "plus"

    var currentVisibility : Visibility {
        colorScheme == .dark ? .hidden : .visible
    }

    //MARK: - INITIALIZATION
    init(vm: CategoriesProductsViewModel = CategoriesProductsViewModel()) {
        _vm = StateObject(wrappedValue: vm)
    }

    //MARK: - FUNCTIONS
    private func editProduct(_ product: DMProduct) {
        vm.selectedProduct = product
        vm.showingEditProductView = true
        print("Edit item: \(String(describing: vm.selectedProduct))")
    }


    //MARK: - BODY
    var body: some View {
        VStack {
            if !vm.categories.isEmpty && !vm.products.isEmpty {
                List {
                    ForEach(vm.categories, id: \.objectID) { category in
                        Section(header:
                            HStack {
                                HStack {
                                    Text(category.name!)
                                        .font(.system(size: 18, weight: .thin ))
                                }

                                Spacer()

                                Image(systemName: category.expanded ? "chevron.down" : "chevron.right")
                            } //: HSTACK
                        .contentShape(Rectangle()) // Makes the whole header tappable
                        .onTapGesture {
                            withAnimation {
                                category.expanded.toggle()
                                vm.saveUpdates()
                            }
                        }) {
                            if(category.expanded) {
                                ForEach(vm.getProductsByCategory(category)) { product in
                                    ProductRowViewCell(vm: vm, product: product, actionEditProduct: {editProduct(product)})
                                }
                            }
                        }
                        .listRowBackground(Color.background)
                        .listSectionSpacing(0)
                        .listRowSeparator(.hidden)
                    } //: LOOP
//                    .padding(.top, -10)
                } //: LIST
                .listStyle(GroupedListStyle())
                .listRowSpacing(-3)
                .onAppear {
                    vm.loadCategoriesProductsData()
                }
                .navigationTitle(Text(categoriesTitle))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .safeAreaInset(
                    edge: .bottom,
                    content: {
                        MainAddButtonView(
                            addButtonLabel: addProductLabel,
                            addButtonIcon: addIcon,
                            addButtonAction: {vm.showingAddProductView = true}
                        )
                    })
                .toolbarBackground(Color.background, for: .navigationBar)
                .toolbar {
                    toolbarContentView(router: router, route: .categories)
                }
                .scrollContentBackground(currentVisibility)
            } else {
                ZStack {
                    Color.background
                        .ignoresSafeArea(edges: .all)
                    VStack {
                        Text("No categories or products found.")
                            .foregroundColor(Color.mediumBlue)
                    }
                    .padding(.vertical, 3)
                }
            }
        } //: VSTACK MAIN

        .background(Color.background, ignoresSafeAreaEdges: .all)
        .sheet(isPresented: $vm.showingAddProductView) {
            AddUpdateCategoryProductView()
                .padding(.top, 20)
                .presentationDetents([.height(260)])
                .presentationBackground(Color.background)
        }
        // TODO - ADD EDIT PRODUCT
//        .sheet(isPresented: $vm.showingEditProductView) {
//            AddUpdateCategoryProductView()
//                .padding(.top, 20)
//                .presentationDetents([.height(260)])
//                .presentationBackground(Color.background)
//        }

    } //: VIEW
}

//MARK: - PREVIEW
#Preview {
    CategoriesProductsView(vm: CategoriesProductsViewModel())
        .environmentObject(NavigationRouter())
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

#Preview("Mocked Data") {
    NavigationStack{
        let previewVM = CategoriesProductsViewModel(persistenceManager: PersistenceManager(context: PersistenceController.previewCategoriesProducts.container.viewContext))

        CategoriesProductsView(vm: previewVM)
            .environmentObject(NavigationRouter())
            .environment(\.managedObjectContext, PersistenceController.previewCategoriesProducts.container.viewContext)
    }
}
