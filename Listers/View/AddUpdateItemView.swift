//
//  AddUpdateItemView.swift
//  Listers
//
//  Created by Edu Caubilla on 13/6/25.
//

import SwiftUI

struct AddUpdateItemView: View {
    //MARK: - PROPERTIES
    @Environment(\.dismiss) var dismiss

    @ObservedObject var vm: MainItemsListsViewModel

    var priorities: [String] = Priority.allCases

    @State private var name : String = ""
    @State private var description : String = ""
    @State private var quantity : String = ""
    @State private var favorite : Bool = false
    @State private var priority : Priority = .normal

    private var itemToUpdate : DMItem?
    private var isItemToUpdate : Bool = false

    @State private var errorShowing : Bool = false
    @State private var errorTitle : String = ""
    @State private var errorMessage : String = ""

    @FocusState private var isFocused: Bool

    var itemTitle : String {
        isItemToUpdate ? "Edit Item" : "New Item"
    }

    //MARK: - INITIALIZER
    init(vm: MainItemsListsViewModel) {
        self.vm = vm
    }

    init (item: DMItem? = nil, vm: MainItemsListsViewModel) {
        if let item = item {
            _name = State(initialValue: item.name ?? "Unknown")
            _description = State(initialValue:item.note ?? "")
            _quantity = State(initialValue:String(item.quantity))
            _favorite = State(initialValue:item.favorite)
            _priority = State(initialValue:Priority(rawValue: item.priority!)!)
        }

        itemToUpdate = item
        isItemToUpdate = true

        self.vm = vm
    }

    //MARK: - FUNCTIONS
    private func saveNewItem() {
        if !name.isEmpty {
            vm.addItem(
                name: name,
                description: description,
                quantity: Int16(
                    quantity
                ) ?? 0,
                favorite: favorite,
                priority: priority,
                completed: false,
                selected: false,
                creationDate: Date.now,
                endDate: Date.now,
                image: "",
                link: "",
                listId: vm.selectedList?.id
            )
        }
        else {
            errorShowing = true
            errorTitle = "Invalid name"
            errorMessage = "Please enter a name for your todo item."
            return
        }
    }

    private func updateItem() {
        if let itemToUpdate = itemToUpdate {
            itemToUpdate.name = name
            itemToUpdate.note = description
            itemToUpdate.quantity = Int16(quantity) ?? 0
            itemToUpdate.favorite = favorite
            itemToUpdate.priority = priority.rawValue

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

                //MARK: - QUANTITY
                TextField(quantity.count == 0 ? "Add quantity" : String(quantity), text: $quantity)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                    .autocorrectionDisabled(true)
                    .foregroundStyle(.primaryText)

                Divider()

                //MARK: - FAVORITE
                Toggle("Favorite", isOn: $favorite)
                    .padding(.top, 5)

//                    //MARK: - DATE PICKER
//                    DatePicker("End date", selection: $endDate)
//                        .datePickerStyle(.compact)
//                        .padding(.top, 10)

                //MARK: - PRIORITY
                Picker("Priority", selection: $priority) {
                    Text("Normal").tag(Priority.normal)
                    Text("High").tag(Priority.high)
                    Text("Very High").tag(Priority.veryHigh)
                } //: PICKER
                .pickerStyle(.segmented)
                .padding(.top, 5)

                //MARK: - SAVE BUTTON
                SaveButtonView(text: "Save", action: {
                    if(isItemToUpdate) {
                        updateItem()
                    } else {
                        saveNewItem()
                    }
                    dismiss()
                })
                .padding(.top, 10)

                //MARK: - SEARCH BUTTON
                if(!isItemToUpdate) {
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
    AddUpdateItemView(vm: MainItemsListsViewModel())
}
