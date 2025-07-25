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
    @State private var selectedCategory : Categories = .Grocery

    private var productToUpdate : DMProduct?
    private var isProductToUpdate : Bool = false

    private var scrollViewProxy : ScrollViewProxy?

    @State private var errorShowing : Bool = false
    @State private var errorTitle : String = ""
    @State private var errorMessage : String = ""
    @State private var firstErrorButtonLabel : String = ""
    @State private var firstErrorButtonAction : () -> Void = { }
    @State private var secondErrorButtonLabel : String = ""
    @State private var secondErrorButtonAction : () -> Void = { }

    @FocusState private var isNameTextFieldFocused : Bool

    var productTitle : String {
        isProductToUpdate ? L10n.shared.localize("form_product_title_edit") : L10n.shared.localize("form_product_title_new")
    }

    //MARK: - INITIALIZER
    init(vm: CategoriesProductsViewModel, scrollViewProxy: ScrollViewProxy? = nil) {
        self.vm = vm
        self.scrollViewProxy = scrollViewProxy
    }
    
    init(product: DMProduct? = nil, vm: CategoriesProductsViewModel, scrollViewProxy: ScrollViewProxy? = nil) {
        self.vm = vm

        if let product = product {
            _name = State(initialValue: product.name ?? L10n.shared.localize("form_product_unknown"))
            _description = State(initialValue:product.notes ?? "")
            _favorite = State(initialValue:product.favorite)
            _active = State(initialValue:product.active)
            _selectedCategory = State(initialValue:Categories.idMapper(for: product.categoryId))
        }

        print("Init FormProductView to EDIT: \(String(describing: product?.name))")

        productToUpdate = product
        isProductToUpdate = true

        self.scrollViewProxy = scrollViewProxy
    }

    //MARK: - FUNCTIONS
    private func saveNewProduct() {
        if name.isEmpty {
            errorShowing = true
            errorTitle = L10n.shared.localize("form_product_invalid_name")
            errorMessage = L10n.shared.localize("form_product_invalid_name_message")
            firstErrorButtonLabel = L10n.shared.localize("form_product_ok")
            return
        }

        if checkNewProductInLibrary() {
            errorShowing = true
            errorTitle = L10n.shared.localize("form_product_invalid_duplicate")
            errorMessage = L10n.shared.localize("form_product_invalid_duplicate_message")
            firstErrorButtonLabel = L10n.shared.localize("form_product_ok")
            firstErrorButtonAction = { name = "" }
            secondErrorButtonLabel = L10n.shared.localize("form_product_continue")
            secondErrorButtonAction = { }
            return
        }

        _ = vm.saveProduct(
            name: name,
            description: description,
            categoryId: selectedCategory.categoryId,
            active: true,
            favorite: favorite
        )

        scrollToProduct()
    }

    private func checkNewProductInLibrary() -> Bool {
        vm.products.contains(where: { $0.name == name })
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
                vm.activeAlert = ProductAlertManager(type: .edited)
            }
        } else {
            print("Item could not be updated.")
        }
    }

    private func scrollToProduct() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard let scrollProxy = scrollViewProxy else {
                print("FormProductView after save product, error trying to scroll as ScrollViewProxy is nil")
                return
            }
            vm.scrollToFoundProduct(proxy: scrollProxy, name: name)
        }
    }

    private func getCategoryFromProductName(_ name: String) -> Categories {
        if let categoryId = vm.getCategoryIdByProductName(name) {
            return Categories.idMapper(for: Int16(categoryId))
        }
        print(selectedCategory)
        return selectedCategory
    }

    private func closeCurrentFormProductView() {
        isProductToUpdate ? vm.changeFormViewState(to: .closeUpdateProduct) : vm.changeFormViewState(to: .closeAddProduct)
    }

    //MARK: - BODY
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    //MARK: - MAIN FORM
                    VStack {
                        TextField(name.isEmpty ? L10n.shared.localize("form_product_add_name") : name, text: $name)
                            .autocorrectionDisabled(true)
                            .focused($isNameTextFieldFocused)
                            .foregroundStyle(.primaryText)

                        Divider()

                        //MARK: - DESCRIPTION
                        TextField(description.isEmpty ? L10n.shared.localize("form_product_add_description") : description, text: $description)
                            .autocorrectionDisabled(true)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .autocorrectionDisabled(true)
                            .foregroundStyle(.primaryText)

                        Divider()

                        //MARK: - CATEGORY
                        HStack {
                            Text(L10n.shared.localize("form_product_add_category"))

                            Spacer()

                            Picker(L10n.shared.localize("form_product_add_category"), selection: $selectedCategory) {
                                ForEach(Categories.allCases, id: \.self) { category in
                                    Text(category.localizedDisplayName).tag(category)
                                }
                            } //: PICKER
                            .pickerStyle(MenuPickerStyle())
                            .padding(.trailing, -10)
                        }

                        //MARK: - FAVORITE
                        Toggle(L10n.shared.localize("form_product_add_favorite"), isOn: $favorite)
                            .padding(.top, 5)

//                        //MARK: - ACTIVE //TODO - only in edit
//                        Toggle("Active", isOn: $active)
//                            .padding(.top, 5)

                        //MARK: - SAVE BUTTON
                        SaveButtonView(text: L10n.shared.localize("form_product_save"), action: {
                            if isProductToUpdate {
                                updateProduct()
                            } else {
                                saveNewProduct()
                            }
                            closeCurrentFormProductView()
                        })
                        .padding(.top, 10)
                    } //: VSTACK MAIN
                } //: VSTACK
                .padding(20)

                Spacer()
            } //: VSTACK
            .navigationTitle(Text(productTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        closeCurrentFormProductView()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.darkBlue)
                    } //: DISSMISS BUTTON
                }
            } //: TOOLBAR
            .alert(errorTitle, isPresented: $errorShowing, actions: {
                Button(firstErrorButtonLabel) {
                    firstErrorButtonAction()
                }
                if(!secondErrorButtonLabel.isEmpty) {
                    Button(secondErrorButtonLabel) {
                        secondErrorButtonAction()
                    }
                }
            }, message: {
                Text(errorMessage)
            })
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
