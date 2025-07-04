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

//    @ObservedObject var vm: MainItemsViewModel

    @State private var name : String = ""
    @State private var description : String = ""
    @State private var favorite : Bool = false
    @State private var active : Bool = true
    @State private var category : String = "General"
    @State private var selectedCategory : String = "General" // TODO ENUM CATEGORIES

    private var isProductToUpdate : Bool = false
    private var productToUpdate : DMProduct?

    @State private var errorShowing : Bool = false
    @State private var errorTitle : String = ""
    @State private var errorMessage : String = ""

    @FocusState private var isFocused: Bool

    var itemTitle : String {
        isProductToUpdate ? "Edit Product" : "New Product"
    }

    //MARK: - INITIALIZER
//    init(vm: MainItemsViewModel) {
//        self.vm = vm
//    }

//    init (item: DMItem? = nil, vm: MainItemsViewModel) {
//        if let item = item {
//            _name = State(initialValue: item.name ?? "Unknown")
//            _description = State(initialValue:item.note ?? "")
//            _quantity = State(initialValue:String(item.quantity))
//            _favorite = State(initialValue:item.favorite)
//            _priority = State(initialValue:Priority(rawValue: item.priority!)!)
//        }
//
//        itemToUpdate = item
//        isItemToUpdate = true
//
//        self.vm = vm
//    }


    //MARK: - FUNCTIONS
    private func saveNewProduct() {
        if !name.isEmpty {

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
//            productToUpdate.categoryId = 1 //TODO map from enum to number

//            vm.saveUpdates()
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

                //MARK: - FAVORITE
                Toggle("Favorite", isOn: $favorite)
                    .padding(.top, 5)

                //MARK: - CATEGORY //TODO
                Picker("Category", selection: $selectedCategory) {
//                    Text("Light").tag(SettingsViewMode.light.rawValue)
//                    Text("Dark").tag(SettingsViewMode.dark.rawValue)
//                    Text("Automatic").tag(SettingsViewMode.automatic.rawValue)
                }
//                Picker("Category", selection: $priority) {
//                    Text("Normal").tag(Priority.normal)
//                    Text("High").tag(Priority.high)
//                    Text("Very High").tag(Priority.veryHigh)
//                } //: PICKER
//                .pickerStyle(.segmented)
//                .padding(.top, 5)

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
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    //TODO - Open products page as sheet
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.darkBlue)
                } //: SEARCH BUTTON
            }
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
    AddUpdateCategoryProductView()
}
