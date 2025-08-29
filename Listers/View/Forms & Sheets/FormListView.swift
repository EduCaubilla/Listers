//
//  AddUpdateListView.swift
//  Listers
//
//  Created by Edu Caubilla on 25/6/25.
//

import SwiftUI

struct FormListView: View {
    //MARK: - PROPERTIES
    @ObservedObject var vm: MainItemsListsViewModel

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var creationDate: Date = Date.now
    @State private var endDate: Date = Date.now
    @State private var pinned: Bool = false
    @State private var expanded: Bool = false

    private var isListToUpdate: Bool = false
    private var listToUpdate: DMList?

    @State private var errorFormListShowing : Bool = false
    private var errorTitle : String = L10n.shared.localize("form_list_invalid_name")
    private var errorMessage : String = L10n.shared.localize("form_list_invalid_name_message")

    @FocusState private var isFocused: Bool

    var listTitle : String {
        isListToUpdate ? L10n.shared.localize("form_list_title_edit") : L10n.shared.localize("form_list_title_new")
    }

    //MARK: - INITIALIZER
    init(vm: MainItemsListsViewModel) {
        self.vm = vm
    }

    init(vm: MainItemsListsViewModel, list: DMList? = nil) {
        self.vm = vm

        if let list = list {
            _name = State(initialValue: list.name ?? L10n.shared.localize("form_list_unknown"))
            _description = State(initialValue: list.notes ?? "")
            _pinned = State(initialValue: list.pinned)
        }

        listToUpdate = list
        isListToUpdate = true

        print("List to edit")
        print("list name: \(list?.name ?? "Unknown"), list description: \(list?.description ?? "Unknown")")
    }

    //MARK: - FUNCTIONS
    private func saveNewList() {
        if !name.isEmpty {
            vm.addList(
                name: name,
                description: description,
                creationDate: Date.now,
                endDate: endDate,
                pinned: pinned,
                selected: false,
                expanded: expanded
            )
        }
        else {
            errorFormListShowing = true
            return
        }
    }

    private func updateList() {
        if let listToUpdate = listToUpdate {
            listToUpdate.name = name
            listToUpdate.notes = description
            listToUpdate.pinned = pinned

            vm.saveItemListsChanges()
        } else {
            print("List could not be updated.")
        }
    }

    //MARK: - BODY
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    //MARK: - NAME
                    TextField(L10n.shared.localize("form_list_add_name"), text: $name)
                        .focused($isFocused)
                        .lineLimit(1)
                        .autocorrectionDisabled(true)
                        .accessibilityIdentifier("list_name_field")

                    Divider()

                    //MARK: - DESCRIPTION
                    if vm.isListDescriptionVisible {
                        TextField(L10n.shared.localize("form_list_add_description"), text: $description)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .autocorrectionDisabled(true)

                        Divider()
                    }


                    //MARK: - END DATE
                    if vm.isListEndDateVisible {
                        DatePicker(L10n.shared.localize("form_list_end_date"), selection: $endDate, displayedComponents: .date)
                            .padding(.top, 5)
                            .datePickerStyle(.compact)
                    }

                    //MARK: - PINNED
                    Toggle(L10n.shared.localize("form_list_pin"), isOn: $pinned)
                        .padding(.top, 5)

                    SaveButtonView(text: L10n.shared.localize("form_list_save"), action: {
                        if(isListToUpdate) {
                            updateList()
                        } else {
                            saveNewList()
                        }
                        isListToUpdate ? vm.changeFormViewState(to: .closeUpdateList) : vm.changeFormViewState(to: .closeAddList)
                    })
                    .padding(.top, 10)
                    .accessibilityIdentifier("save_list_button")

                } //: VSTACK
                .padding(20)

                Spacer()
            } //: VSTACK
            .navigationTitle(listTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        isListToUpdate ? vm.changeFormViewState(to: .closeUpdateList) : vm.changeFormViewState(to: .closeAddList)
                    }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.darkBlue)
                    } //: DISSMISS BUTTON
                }
            }
            .alert(isPresented: $errorFormListShowing) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text(L10n.shared.localize("form_list_ok"))))
            }
            .onAppear{
                isFocused = true
            }
        }
    } // VIEW
}

//MARK: - PREVIEW
#Preview {
    FormListView(vm: MainItemsListsViewModel())
}
