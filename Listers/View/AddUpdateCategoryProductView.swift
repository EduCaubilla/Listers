//
//  AddUpdateItemView.swift
//  Listers
//
//  Created by Edu Caubilla on 13/6/25.
//

import SwiftUI

struct AddUpdateCategoryProductView: View {
    //MARK: - PROPERTIES
    @Environment(\.dismiss) var dismiss

    @ObservedObject var vm: CategoriesProductsViewModel

    @State private var name : String = ""
    @State private var description : String = ""
    @State private var favorite : Bool = false
    @State private var active : Bool = true
    @State private var category : String = "General"
    @State private var selectedCategory : Categories = .Grocery

    private var productToUpdate : DMProduct?
    private var isProductToUpdate : Bool = false

    @State private var errorShowing : Bool = false
    @State private var errorTitle : String = ""
    @State private var errorMessage : String = ""

    @FocusState private var isNameTextFieldFocused: Bool
    @FocusState private var isSearchBarFocused: Bool

    @State private var showSearchBar: Bool = false
    @State private var searchText: String = ""

    var searchResults: [String] {
        return vm.productNames.filter { $0.lowercased().contains(searchText.lowercased()) }
    }

    var itemTitle : String {
        isProductToUpdate ? "Edit Product" : "New Product"
    }

    //MARK: - INITIALIZER
    init(vm: CategoriesProductsViewModel) {
        self.vm = vm
    }
    
    init(product: DMProduct? = nil, vm: CategoriesProductsViewModel) {
        if let product = product {
            _name = State(initialValue: product.name ?? "Unknown")
            _description = State(initialValue:product.note ?? "")
            _favorite = State(initialValue:product.favorite)
            _active = State(initialValue:product.active)
            _selectedCategory = State(initialValue:Categories.idMapper(for: product.categoryId))
        }

        print("Init AddUpdateCategoryProductView to EDIT")
        print(product ?? "No item passed")

        productToUpdate = product
        isProductToUpdate = true

        self.vm = vm
    }

    //MARK: - FUNCTIONS
    private func saveNewProduct() {
        if !name.isEmpty {
            vm.saveNewProduct(
                id: vm.createIdForNewProduct(),
                name: name,
                description: description,
                categoryId: selectedCategory.categoryId,
                active: active,
                favorite: favorite
            )
        }
        else {
            errorShowing = true
            errorTitle = "Invalid name"
            errorMessage = "Please enter a name for your todo item."
            return
        }
    }

    private func updateProduct() {
        if let productToUpdate = productToUpdate {
            productToUpdate.name = name
            productToUpdate.note = description
            productToUpdate.favorite = favorite
            productToUpdate.active = active
            productToUpdate.categoryId = Int16(selectedCategory.categoryId)

            vm.saveUpdates()
        } else {
            print("Item could not be updated.")
        }
    }

    private func getCategoryFromProductName(_ name: String) -> Categories {
        if let categoryId = vm.getCategoryIdByProductName(name) {
            return Categories.idMapper(for: Int16(categoryId))
        }
        print(selectedCategory)
        return selectedCategory
    }

    //MARK: - BODY
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                //MARK: - MAIN FORM
                VStack {
                    TextField(name.isEmpty ? "Add Name" : name, text: $name)
                        .autocorrectionDisabled(true)
                        .focused($isNameTextFieldFocused)
                        .foregroundStyle(.primaryText)
                        .onChange(of: name) { oldValue, newValue in
                            showSearchBar = false
                            if newValue == "" {
                                selectedCategory = .allCases.first!
                            }
                        }

                    Divider()

                    //MARK: - DESCRIPTION
                    TextField(description.isEmpty ? "Add description" : description, text: $description)
                        .autocorrectionDisabled(true)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .autocorrectionDisabled(true)
                        .foregroundStyle(.primaryText)

                    Divider()

                    //MARK: - CATEGORY
                    HStack {
                        Text("Category")

                        Spacer()

                        Picker("Category", selection: $selectedCategory) {
                            ForEach(Categories.allCases, id: \.self) { category in
                                Text(category.displayName).tag(category)
                            }
                        } //: PICKER
                        .pickerStyle(MenuPickerStyle())
                        .padding(.trailing, -10)
                    }

                    //MARK: - FAVORITE
                    Toggle("Favorite", isOn: $favorite)
                        .padding(.top, 5)


                    //MARK: - ACTIVE //TODO - only in edit
                    Toggle("Active", isOn: $active)
                        .padding(.top, 5)


                    //MARK: - SAVE BUTTON
                    SaveButtonView(text: "Save", action: {
                        if(isProductToUpdate) {
                            updateProduct()
                        } else {
                            saveNewProduct()
                        }
                        dismiss()
                    })
                    .padding(.top, 10)
                } //: VSTACK MAIN
                .onTapGesture {
                    if showSearchBar {
                        showSearchBar = false
                    }
                }

                //MARK: - SEARCH BUTTON
                VStack {
                    if !isProductToUpdate {
                        if !showSearchBar {
                            Button(action: {
                                //TODO - Open products page as sheet
                                showSearchBar = true
                            }) {
                                Text("Search in products")
                                    .font(.system(size: 20, weight: .medium))
                                    .padding(10)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .background(
                                        Capsule()
                                            .fill(Color.background)
                                            .stroke(Color.mediumBlue, lineWidth: 1)
                                    )
                                    .foregroundStyle(.lightBlue)
                            } //: SEARCH BUTTON
                        } else {
                            VStack {
                                HStack {
                                    TextField("Search...", text: $searchText)
                                        .autocorrectionDisabled(true)
                                        .textFieldStyle(.plain)

                                        .focused($isSearchBarFocused)
                                        .onAppear {
                                            isSearchBarFocused = true
                                        }
                                        .onSubmit {
                                            self.name = searchText
                                            withAnimation {
                                                self.selectedCategory = getCategoryFromProductName(searchText)
                                            }
                                        }

                                    Spacer()

                                    Image(systemName: "xmark.circle.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(.gray)
                                        .onTapGesture {
                                            showSearchBar = false
                                        }
                                } //: HSTACK - SEARCHBAR
                                .padding(.horizontal, 15)
                                .padding(.vertical, 11)
                                .background(
                                    Capsule()
                                        .fill(Color.background)
                                        .stroke(Color.mediumBlue, lineWidth: 1)
                                )

                                VStack {
                                    List(searchResults, id: \.self) { name in
                                        Text(name)
                                            .onTapGesture {
                                                self.name = name
                                                withAnimation {
                                                    self.selectedCategory = getCategoryFromProductName(name)
                                                }
                                                showSearchBar = false
                                                searchText = ""
                                            }
                                            .listRowBackground(Color.background)
//                                            .listRowSeparator(.hidden)
                                    } //: LIST - SEARCH OPTIONS
                                    .scrollIndicators(.visible)
                                    .scrollContentBackground(.hidden)
                                    .listStyle(.inset)
                                    .listRowSpacing(-5)
                                    .padding(EdgeInsets(top: -8, leading: -5, bottom: 10, trailing: 0))
                                } //: VSTACK
                            } //: VSTACK SEARCH BLOCK
                        }
                    }
                } //: VSTACK SEARCH
                .animation(.easeInOut, value: showSearchBar)
            } //: VSTACK
            .padding(20)

            Spacer()
        } //: VSTACK
        .navigationTitle(Text(itemTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(.darkBlue)
                } //: DISSMISS BUTTON
            }
        }
        .alert(isPresented: $errorShowing) {
            Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear{
            isNameTextFieldFocused = true
        }
        .background(Color.background)
    } //: VIEW
}


//MARK: - PREVIEW
#Preview {
    AddUpdateCategoryProductView(vm: CategoriesProductsViewModel())
}
