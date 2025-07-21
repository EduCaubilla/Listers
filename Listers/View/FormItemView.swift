//
//  FormItemView.swift
//  Listers
//
//  Created by Edu Caubilla on 13/6/25.
//

import SwiftUI

struct FormItemView: View {
    //MARK: - PROPERTIES
    @ObservedObject var vm: MainItemsListsViewModel

    var priorities: [String] = Priority.allCases

    @State private var name : String = ""
    @State private var description : String = ""
    @State private var quantity : String = ""
    @State private var favorite : Bool = false
    @State private var endDate : Date = Date.now
    @State private var priority : Priority = .normal

    private var itemToUpdate : DMItem?
    private var isItemToUpdate : Bool = false

    @State private var errorShowing : Bool = false
    @State private var errorTitle : String = ""
    @State private var errorMessage : String = ""

    @FocusState private var isNameTextFieldFocused: Bool
    @FocusState private var isDescriptionFieldFocused: Bool

    @State private var searchText: String = ""
    @State private var showNameSuggestions: Bool = false
    @State private var nameSetFromList: String = ""

    var searchResults: [String] {
        print("Search results ongoing...")
        return vm.productNames.filter { $0.lowercased().contains(name.lowercased()) }
    }

    var itemTitle : String {
        isItemToUpdate ? "Edit Item" : "New Item"
    }

    //MARK: - INITIALIZER
    init(vm: MainItemsListsViewModel) {
        self.vm = vm
    }

//    init (item: DMItem?, vm: MainItemsListsViewModel) {
    init (item: DMItem? = nil, vm: MainItemsListsViewModel) {
        self.vm = vm

        if let item = item {
            _name = State(initialValue: item.name ?? "Unknown Item")
            _description = State(initialValue: item.notes ?? "")
            _quantity = State(initialValue: item.quantity.trimmedString)
            _favorite = State(initialValue: item.favorite)
            _priority = State(initialValue: Priority(rawValue: item.priority!)!)
            _endDate = State(initialValue: endDate)

            itemToUpdate = item
            isItemToUpdate = true
        }
    }

    //MARK: - FUNCTIONS
    private func triggerAlertSaveNewItemForLibrary() {
        if (!searchResults.contains(name) && !isItemToUpdate) {
            vm.showSaveNewProductMessage = true
        } else {
            vm.changeFormViewState(to: .closeAddItem)
        }
    }
    
    private func saveNewItem() {
        if !name.isEmpty {
            vm.addItemToList(
                name: name,
                description: description,
                quantity: Double(quantity) ?? 0,
                favorite: favorite,
                priority: priority,
                completed: false,
                selected: false,
                creationDate: Date.now,
                endDate: endDate,
                image: "",
                link: "",
                listId: vm.selectedList?.id
            )

            triggerAlertSaveNewItemForLibrary()

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
            itemToUpdate.notes = description
            itemToUpdate.quantity = Double(quantity) ?? 0
            itemToUpdate.favorite = favorite
            itemToUpdate.endDate = endDate
            itemToUpdate.priority = priority.rawValue

            vm.saveItemListsChanges()
        } else {
            print("Item could not be updated.")
        }
    }

    private func closeCurrentFormItemView() {
        isItemToUpdate ? vm.changeFormViewState(to: .closeUpdateItem) : vm.changeFormViewState(to: .closeAddItem)
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
                                    isNameTextFieldFocused = false
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
                    .onAppear(perform: {
                        if isItemToUpdate {
                            showNameSuggestions = false
                        }
                    })
                    .onChange(of: name) { oldValue, newValue in
                        if oldValue == nameSetFromList, !searchResults.isEmpty {
                            showNameSuggestions = true
                        }

                        if searchResults.isEmpty || newValue == nameSetFromList {
                            showNameSuggestions = false
                        } else if !searchResults.isEmpty &&
                                !showNameSuggestions &&
                                nameSetFromList != name {
                            showNameSuggestions = true
                        }
                        print("Text changed: \(oldValue) -> \(newValue)")
                    }

                    ZStack {
                        VStack(spacing: 10) {
                            //MARK: - DESCRIPTION
                            if vm.isItemDescriptionVisible {
                                TextField(description.isEmpty ? "Add description" : description, text: $description)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(3)
                                    .autocorrectionDisabled(true)
                                    .foregroundStyle(.primaryText)
                                    .focused($isDescriptionFieldFocused)

                                Divider()
                            }

                            //MARK: - QUANTITY
                            if vm.isItemQuantityVisible {
                                TextField(quantity.count == 0 ? "Add quantity" : quantity, text: $quantity)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(4)
                                    .autocorrectionDisabled(true)
                                    .foregroundStyle(.primaryText)

                                Divider()
                            }

                            //MARK: - FAVORITE
                            Toggle("Favorite", isOn: $favorite)
                                .padding(.top, 5)
                            
                            //MARK: - DATE PICKER
                            if vm.isItemEndDateVisible {
                                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .padding(.top, 10)
                            }

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
                                    closeCurrentFormItemView()
                                } else {
                                    saveNewItem()
                                }
                            })
                            .padding(.top, 10)

                            Spacer()
                    } //: VSTACK FORM

                        //MARK: - SUGGESTION LIST
                        if showNameSuggestions, !searchResults.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                List(searchResults, id: \.self) { name in
                                    Text(name)
                                        .onTapGesture {
                                            self.name = name
                                            self.nameSetFromList = name
                                            showNameSuggestions = false
                                            print("Name set from list \(name)")
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
                        }
                    } //: ZSTACK
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
                        closeCurrentFormItemView()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.darkBlue)
                    } //: DISSMISS BUTTON
                }
            } //: TOOLBAR
            .onAppear{
                isNameTextFieldFocused = true
            }
            .alert(isPresented: $errorShowing) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .alert("The item \(name) is not on your product's library yet.\nWould you like to add it?", isPresented: $vm.showSaveNewProductMessage, presenting: name) { name in
                Button("Cancel", role: .cancel){
                    vm.showSaveNewProductMessage = false
                    closeCurrentFormItemView()
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
                    vm.showSaveNewProductMessage = false
                    vm.loadProductNames()

                    closeCurrentFormItemView()
                }
            }
        } //: NAVIGATION STACK
    } //: VIEW
}


//MARK: - PREVIEW
#Preview {
    FormItemView(vm: MainItemsListsViewModel())
}
