//
//  FormItemView.swift
//  Listers
//
//  Created by Edu Caubilla on 13/6/25.
//

import SwiftUI

struct FormProductView: View {
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

    var itemTitle : String {
        isProductToUpdate ? "Edit Product" : "New Product"
    }

    //MARK: - INITIALIZER
    init(vm: CategoriesProductsViewModel) {
        self.vm = vm
    }
    
    init(product: DMProduct? = nil, vm: CategoriesProductsViewModel) {
        self.vm = vm

        if let product = product {
            _name = State(initialValue: product.name ?? "Unknown")
            _description = State(initialValue:product.notes ?? "")
            _favorite = State(initialValue:product.favorite)
            _active = State(initialValue:product.active)
            _selectedCategory = State(initialValue:Categories.idMapper(for: product.categoryId))
        }

        print("Init AddUpdateCategoryProductView to EDIT: \(String(describing: product?.name))")

        productToUpdate = product
        isProductToUpdate = true
    }

    //MARK: - FUNCTIONS
    private func saveNewProduct() {
        if !name.isEmpty {
            vm.saveNewProduct(
                name: name,
                description: description,
                categoryId: selectedCategory.categoryId,
                active: true,
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
            productToUpdate.notes = description
            productToUpdate.favorite = favorite
            productToUpdate.active = active
            productToUpdate.categoryId = Int16(selectedCategory.categoryId)

            print("SAVE Updated product \(String(describing: productToUpdate.name))")

            vm.saveCategoriesProductsUpdates()

            vm.setSelectedProduct(productToUpdate)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                vm.activeAlert = ProductAlert(type: .edited)
            }
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
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    //MARK: - MAIN FORM
                    VStack {
                        TextField(name.isEmpty ? "Add Name" : name, text: $name)
                            .autocorrectionDisabled(true)
                            .focused($isNameTextFieldFocused)
                            .foregroundStyle(.primaryText)

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

//                        //MARK: - ACTIVE //TODO - only in edit
//                        Toggle("Active", isOn: $active)
//                            .padding(.top, 5)

                        //MARK: - SAVE BUTTON
                        SaveButtonView(text: "Save", action: {
                            if isProductToUpdate {
                                updateProduct()
                            } else {
                                saveNewProduct()
                            }
                            dismiss()
                        })
                        .padding(.top, 10)
                    } //: VSTACK MAIN
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
            } //: TOOLBAR
            .alert(isPresented: $errorShowing) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear{
                isNameTextFieldFocused = true
            }
            .background(Color.background)
        } //: NAVIGATION STACK
    } //: VIEW MAIN
}


//MARK: - PREVIEW
#Preview {
    FormProductView(vm: CategoriesProductsViewModel())
}
