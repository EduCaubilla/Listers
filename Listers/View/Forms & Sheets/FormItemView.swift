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

    var priorities: [String] = Priority.allLocalizedCases

    @State private var name : String = ""
    @State private var description : String = ""
    @State private var quantity : String = ""
    @State private var favorite : Bool = false
    @State private var endDate : Date = Date.now
    @State private var priority : Priority = .normal

    private var itemToUpdate : DMItem?
    private var isItemToUpdate : Bool = false

    @State private var errorFormItemShowing : Bool = false
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
        isItemToUpdate ? L10n.shared.localize("form_item_title_edit") : L10n.shared.localize("form_item_title_new")
    }

    //MARK: - INITIALIZER
    init(vm: MainItemsListsViewModel) {
        self.vm = vm
    }

    init (item: DMItem? = nil, vm: MainItemsListsViewModel) {
        self.vm = vm

        if let item = item {
            _name = State(initialValue: item.name ?? L10n.shared.localize("form_item_unknown"))
            _description = State(initialValue: item.notes ?? "")
            _quantity = State(initialValue: String(item.quantity))
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
            vm.showSaveNewProductAlert = true
        } else {
            vm.changeFormViewState(to: .closeAddItem)
        }
    }
    
    private func saveNewItem() {
        if !name.isEmpty {
            vm.addItemToList(
                name: name,
                description: description,
                quantity: Int16(quantity) ?? 0,
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
            errorFormItemShowing = true
            errorTitle = L10n.shared.localize("form_item_invalid_name")
            errorMessage = L10n.shared.localize("form_item_invalid_name_message")
            return
        }
    }

    private func updateItem() {
        if let itemToUpdate = itemToUpdate {
            itemToUpdate.name = name
            itemToUpdate.notes = description
            itemToUpdate.quantity = Int16(quantity) ?? 0
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
                            TextField(name.isEmpty ? L10n.shared.localize("form_item_add_name") : name, text: $name)
                                .autocorrectionDisabled(true)
                                .focused($isNameTextFieldFocused)
                                .foregroundStyle(.primaryText)
                                .onSubmit {
                                    print("Name submitted")
                                    isNameTextFieldFocused = false
                                    isDescriptionFieldFocused = true
                                    showNameSuggestions = false
                                }
                                .accessibilityIdentifier("item_name_field")

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
                    .onAppear{
                        if isItemToUpdate {
                            showNameSuggestions = false
                        }
                    }
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

                    VStack(spacing: 10) {
                        //MARK: - DESCRIPTION
                        if vm.isItemDescriptionVisible {
                            TextField(description.isEmpty ? L10n.shared.localize("form_item_add_description") : description, text: $description)
                                .multilineTextAlignment(.leading)
                                .lineLimit(3)
                                .autocorrectionDisabled(true)
                                .foregroundStyle(.primaryText)
                                .focused($isDescriptionFieldFocused)

                            Divider()
                        }

                        //MARK: - QUANTITY
                        if vm.isItemQuantityVisible {
                            TextField(quantity.count == 0 ? L10n.shared.localize("form_item_add_quantity") : quantity, text: $quantity)
                                .multilineTextAlignment(.leading)
                                .lineLimit(4)
                                .autocorrectionDisabled(true)
                                .foregroundStyle(.primaryText)

                            Divider()
                        }

                        //MARK: - FAVORITE
                        Toggle(L10n.shared.localize("form_item_favorite"), isOn: $favorite)
                            .padding(.top, 10)
                            .accessibilityIdentifier(L10n.shared.localize("form_item_favorite"))

                        //MARK: - DATE PICKER
                        if vm.isItemEndDateVisible {
                            DatePicker(L10n.shared.localize("form_item_end_date"), selection: $endDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .padding(.top, 10)
                        }

                        //MARK: - PRIORITY
                        HStack{
                            Text(L10n.shared.localize("form_item_priority"))

                            Spacer()

                            Picker(L10n.shared.localize("form_item_priority"), selection: $priority) {
                                ForEach(Priority.allCases, id: \.self) { priority in
                                    Text(priority.localizedDisplayName).tag(priority)
                                }
                            } //: PICKER
                            .padding(.trailing, -10)
                            .pickerStyle(.menu)
                        }
                        .padding(.top, 5)

                        //MARK: - SAVE BUTTON
                        SaveButtonView(text: L10n.shared.localize("form_item_save"), action: {
                            if(isItemToUpdate) {
                                updateItem()
                                closeCurrentFormItemView()
                            } else {
                                saveNewItem()
                            }
                        })
                        .padding(.top, 10)
                        .accessibilityIdentifier("save_item_button")

                        Spacer()
                    } //: VSTACK FORM
                    .overlay(alignment: .top) {
                        //MARK: - SUGGESTION LIST
                        if showNameSuggestions, !searchResults.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 5) {
                                    ForEach(searchResults, id: \.self) { name in
                                        Text(name)
                                            .padding(.vertical, 5)
                                            .padding(.leading, 10)
                                            .onTapGesture {
                                                self.name = name
                                                self.nameSetFromList = name
                                                showNameSuggestions = false
                                                print("Name set from list \(name)")
                                            }
                                        Divider()
                                    }
                                } //: VSTACK
                                .background(.backgroundGray)
                                .padding(EdgeInsets(top: 0, leading: -5, bottom: 0, trailing: -2))
                            } //: SCROLLVIEW - SUGGESTIONS
                            .padding(.top, -10)
                            .frame(maxHeight: 240)
                            .allowsHitTesting(true)
                            .shadow(radius: 1)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    } //: OVERLAY
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
            .alert(isPresented: $errorFormItemShowing) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text(L10n.shared.localize("form_item_ok"))))
            }
            //MARK: - ITEM INTO LIBRARY ALERT
            .alert(L10n.shared.localize("form_item_alert_not_library_title", args: name),
                isPresented: $vm.showSaveNewProductAlert) {
                    Button(L10n.shared.localize("form_item_cancel"), role: .cancel){
                    }
                    Button(L10n.shared.localize("form_item_add")){
                        vm.saveProduct(
                            name: name,
                            description: description,
                            categoryId: 10,
                            active: true,
                            favorite: favorite
                        )
                        print("Added product \(name) to library list")
                        vm.showSaveNewProductAlert = false
                        vm.loadProductNames(forceLoad: true)

                        closeCurrentFormItemView()
                    }
                    Button(L10n.shared.localize("form_item_skip")){
                        vm.showSaveNewProductAlert = false
                        closeCurrentFormItemView()
                    }
            } message: {
                Text(L10n.shared.localize("form_item_alert_not_library_message", args: name))
            }
        } //: NAVIGATION STACK
        .onAppear{
            DispatchQueue.main.async {
                vm.loadProductNames()
            }
        }
    } //: VIEW
}


//MARK: - PREVIEW
#Preview {
    FormItemView(vm: MainItemsListsViewModel())
}
