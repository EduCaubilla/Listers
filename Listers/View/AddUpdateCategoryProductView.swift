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

    @FocusState private var isFocused: Bool

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


    //MARK: - BODY
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                //MARK: - NAME
                TextField(name.isEmpty ? "Add Name" : name, text: $name)
                    .autocorrectionDisabled(true)
                    .focused($isFocused)
                    .foregroundStyle(.primaryText)

                Divider()

                //MARK: - DESCRIPTION
                TextField(description.isEmpty ? "Add description" : description, text: $description)
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
                        ForEach(Categories.allCases) { category in
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

                //MARK: - SEARCH BUTTON
                if(!isProductToUpdate) {
                    //TODO - Add search in categories
//                        Button(action: {
//                            //TODO - Open products page as sheet
//
//                        }) {
//                            Text("Search in products")
//                                .font(.system(size: 20, weight: .medium))
//                                .padding(10)
//                                .frame(minWidth: 0, maxWidth: .infinity)
//                                .background(
//                                    Capsule()
//                                        .fill(.white)
//                                        .stroke(Color.darkBlue, lineWidth: 1)
//                                )
//                                .foregroundStyle(.darkBlue)
//                        } //: SEARCH BUTTON
                }
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
//            ToolbarItem(placement: .topBarLeading) {
//                Button(action: {
//                    //TODO - Open products page as sheet
//                }) {
//                    Image(systemName: "magnifyingglass")
//                        .foregroundStyle(.darkBlue)
//                } //: SEARCH BUTTON
//            }
        }
        .alert(isPresented: $errorShowing) {
            Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear{
            isFocused = true
        }
    } //: VIEW
}


//MARK: - PREVIEW
#Preview {
    AddUpdateCategoryProductView(vm: CategoriesProductsViewModel())
}
