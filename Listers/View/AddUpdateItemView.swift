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

    @FocusState private var isNameTextFieldFocused: Bool
    @FocusState private var isDescriptionFieldFocused: Bool

    @State private var searchText: String = ""
    @State private var showNameSuggestions: Bool = true

    @State private var showSaveNewProductAlert: Bool = false


    var searchResults: [String] {
        vm.productNames.filter { $0.lowercased().contains(name.lowercased()) }
    }

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
                quantity: Int16(quantity) ?? 0,
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

            if (!searchResults.contains(name) && !isItemToUpdate) {
                print("OPTION TO SAVE NEW ITEM WITH NAME \(name)")
                showSaveNewProductAlert.toggle()
            }
        } else {
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

            vm.saveItemListsChanges()
        } else {
            print("Item could not be updated.")
        }
    }

    private func finishShowingSuggestions() {
        isNameTextFieldFocused = false
        showNameSuggestions = false
    }

    //MARK: - BODY
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    //MARK: - NAME
                    VStack(spacing: 10) {
                        HStack(alignment: .center, spacing: 10){
                            TextField(name.isEmpty ? "Add Name" : name, text: $name)
                                .autocorrectionDisabled(true)
                                .focused($isNameTextFieldFocused)
                                .foregroundStyle(.primaryText)
                                .onSubmit {
                                    print("Name submitted")
                                    finishShowingSuggestions()
                                    isDescriptionFieldFocused = true
                                }

                            Spacer()

                            if showNameSuggestions,
                               !name.isEmpty {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color.gray)
                                    .onTapGesture {
                                        showNameSuggestions = false
                                    }
                            }
                        }
                        Divider()
                    } //: VSTACK - NAME FIELD
                    .onChange(of: name) { _, _ in
                        showNameSuggestions = !searchResults.isEmpty
                    }

                    ZStack {
                        VStack(spacing: 10) {
                            //MARK: - DESCRIPTION
                            TextField(description.isEmpty ? "Add description" : description, text: $description)
                                .multilineTextAlignment(.leading)
                                .lineLimit(3)
                                .autocorrectionDisabled(true)
                                .foregroundStyle(.primaryText)
                                .focused($isDescriptionFieldFocused)

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
                            .alert("The item saved is not on your product's library yet.\nWould you like to add it?", isPresented: $showSaveNewProductAlert, presenting: name) { name in
                                Button("Cancel", role: .cancel){
                                    showSaveNewProductAlert = false
                                }
                                Button("Add"){
                                    vm.saveNewProduct(
                                        name: name,
                                        description: description,
                                        categoryId: 10,
                                        active: true,
                                        favorite: favorite
                                    )
                                    print("Added product \(name) to library list")
                                    showSaveNewProductAlert = false
                                }
                            }

                            Spacer()
                    } //: VSTACK FORM

                        //MARK: - SUGGESTION LIST
                        if showNameSuggestions, !searchResults.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                List(searchResults, id: \.self) { name in
                                    Text(name)
                                        .onTapGesture {
                                            self.name = name
                                            showNameSuggestions = false
                                        }
                                        .listRowBackground(Color.backgroundGray)
                                } //: LIST - SEARCH OPTIONS
                                .scrollIndicators(.visible)
                                .scrollContentBackground(.hidden)
                                .listStyle(.inset)
                                .listRowSpacing(-5)
                                .padding(EdgeInsets(top: -10, leading: -5, bottom: 0, trailing: -2))

                                Spacer()
                            } //: VSTACK - SUGGESTIONS
                            .onTapGesture {
                                finishShowingSuggestions()
                                print("Tap on results")
                            }
                        }
                    }
                } //: VSTACK
                .padding(.horizontal, 20)
                .padding(.top, 10)

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
        } //: NAVIGATION STACK
    } //: VIEW
}


//MARK: - PREVIEW
#Preview {
    AddUpdateItemView(vm: MainItemsListsViewModel())
}
