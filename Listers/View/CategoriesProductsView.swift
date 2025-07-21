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

    @State private var isShowingFavorites: Bool = false

    @State private var name : String = ""
    @State private var showSearchBar: Bool = false
    @State private var searchBarFixedHeight: Bool = true

    private var categoriesTitle : String = "Categories"
    private var addProductLabel: String = "Add Product"
    private var addIcon: String = "plus"

    private var filteredCategories: [DMCategory] {
        isShowingFavorites ? vm.categories.filter({ $0.favorite }) : vm.categories
    }

    private var currentVisibility : Visibility {
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
    }

    private func setProductSelection(for product: DMProduct) -> Bool {
        return product.name == vm.selectedProduct?.name ?? ""
    }

    private func scrollToFoundProduct(proxy: ScrollViewProxy) {
        let productsToScroll = vm.products.filter { $0.name == name }
        if let productToScroll = productsToScroll.first {
            if let categoryToScroll = vm.getCategoryByProductId(productToScroll.id) {
                print("Category to Scroll: \(String(describing: categoryToScroll.name))")

                for category in vm.categories {
                    if category.id == categoryToScroll.id {
                        print("Category to expand: \(String(describing: category.name))")
                        category.expanded = true
                    } else {
                        print("Category to NOT expand: \(String(describing: category.name))")
                        category.expanded = false
                    }
                }

                vm.saveCategoriesProductsUpdates()

                print("Scroll to found product: \(name) with id: \(productToScroll.id)")
                vm.selectedProduct = productToScroll

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.default){
                        proxy.scrollTo(productToScroll.id, anchor: .center)
                    }
                }
            } else {
                print("Category to scroll to not found with id: \(productToScroll.id)")
            }
        } else {
            print("Product to scroll to not found: \(name)")
        }
    }

    //MARK: - BODY
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            ScrollViewReader { value in
                if showSearchBar {
                    VStack(alignment: .leading, spacing: 0){
                        SearchBarCustomView(name: $name, showSearchBar: $showSearchBar, productNameList: vm.productNames, resultAction: {scrollToFoundProduct(proxy: value)})
                    }
                    .padding(.bottom, 0)
                }
                if !vm.categories.isEmpty && !vm.products.isEmpty {
                    List {
                        ForEach(filteredCategories) { category in
                            Section(header: HStack {
                                HStack {
                                    Text(category.name!)
                                        .font(.system(size: 18, weight: .thin ))
                                }
                                .padding(.leading, -10)

                                Spacer()

                                Image(systemName: category.expanded ? "chevron.down" : "chevron.right")
                                    .padding(.trailing, -10)
                            } //: HSTACK HEADER
                                .contentShape(Rectangle()) // Makes the whole header tappable
                                .onTapGesture {
                                    withAnimation {
                                        category.expanded.toggle()
                                        vm.saveCategoriesProductsUpdates()
                                    }
                                }) {
                                    if(category.expanded) {
                                        ForEach(vm.getFavoriteProducts(for: category,inCase: isShowingFavorites), id: \.id) { product in
                                            HStack {
                                                ProductRowViewCell(vm: vm, product: product, actionEditProduct: {editProduct(product)})
                                            }
                                        }
                                    }
                                } //: SECTION
                                .listRowBackground(Color.background)
                                .listSectionSpacing(0)
                                .listRowSeparator(.hidden)
                        } //: LOOP
                    } //: LIST
                    .listStyle(SidebarListStyle())
                    .listRowSpacing(-3)
                    .onAppear {
                        vm.loadCategoriesProductsData()
                    }
                    .navigationTitle(Text(categoriesTitle))
                    .navigationBarTitleDisplayMode(.inline)
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

                        ToolbarItem(id: "Favorites", showsByDefault: false) {
                            Button(action: {
                                isShowingFavorites.toggle()
                            }) {
                                if isShowingFavorites {
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(.yellow)
                                } else {
                                    Image(systemName: "star")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(.darkBlue)
                                }
                            } //: FAV BUTTON
                            .padding(.trailing, -10)
                        } //: TOOLBAR ITEM

                        ToolbarItem(id: "Search", showsByDefault: true) {
                            Button(action: {
                                showSearchBar = true
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.darkBlue)
                            } //: SEARCH BUTTON
                        } //: TOOLBAR ITEM

                    } //: TOOLBAR
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
                    } //: ZSTACK
                }
            } //: SCROLLVIEWREADER
        } //: VSTACK MAIN
        .background(colorScheme == .light ? Color(UIColor.secondarySystemBackground) : .background, ignoresSafeAreaEdges: .all)
        .sheet(isPresented: $vm.showingAddProductView) {
            FormProductView(vm: vm)
                .padding(.top, 20)
                .presentationDetents([.height(320)])
                .presentationBackground(Color.background)
        }
        .sheet(isPresented: $vm.showingEditProductView) {
            FormProductView(product: vm.selectedProduct, vm: vm)
                .padding(.top, 20)
                .presentationDetents([.height(320)])
                .presentationBackground(Color.background)
        }
        .sheet(isPresented: $vm.showingListSelectionToAddProductView,
               onDismiss: {vm.activeAlert = ProductAlert(type: .addedToSelectedList)}
        ) {
            ListsToAddProductView(vm: MainItemsListsViewModel(), itemToAdd: vm.selectedProduct)
                .padding(.top, 20)
                .presentationDetents([.medium])
                .presentationBackground(Color.background)
        }
    } //: VIEW
}

//MARK: - PREVIEW
#Preview {
    NavigationStack{
        CategoriesProductsView(vm: CategoriesProductsViewModel())
            .environmentObject(NavigationRouter())
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}

#Preview("Mocked Data") {
    NavigationStack{
        let previewVM = CategoriesProductsViewModel(persistenceManager: PersistenceManager(context: PersistenceController.previewCategoriesProducts.container.viewContext))

        CategoriesProductsView(vm: previewVM)
            .environmentObject(NavigationRouter())
            .environment(\.managedObjectContext, PersistenceController.previewCategoriesProducts.container.viewContext)
    }
}
