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

    @State private var errorShowing : Bool = false
    private var errorTitle : String = "Invalid name"
    private var errorMessage : String = "Please enter a name for your new item."

    @FocusState private var isFocused: Bool

    var listTitle : String {
        isListToUpdate ? "Update list" : "New list"
    }

    //MARK: - INITIALIZER
    init(vm: MainItemsListsViewModel) {
        self.vm = vm
    }

    init(vm: MainItemsListsViewModel, list: DMList? = nil) {
        self.vm = vm

        if let list = list {
            _name = State(initialValue: list.name ?? "")
            _description = State(initialValue: list.notes ?? "")
            _pinned = State(initialValue: list.pinned)
        }

        listToUpdate = list
        isListToUpdate = true

        print("List to update")
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
            errorShowing = true
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

    private func closeCurrentListView() {

    }

    //MARK: - BODY
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    //MARK: - NAME
                    TextField("Name", text: $name)
                        .focused($isFocused)
                        .lineLimit(1)
                        .autocorrectionDisabled(true)

                    Divider()

                    //MARK: - DESCRIPTION
                    if vm.isListDescriptionVisible {
                        TextField("Description", text: $description)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .autocorrectionDisabled(true)

                        Divider()
                    }


                    //MARK: - END DATE
                    if vm.isListEndDateVisible {
                        DatePicker("End date", selection: $endDate, displayedComponents: .date)
                            .padding(.top, 5)
                            .datePickerStyle(.compact)
                    }

                    //MARK: - PINNED
                    Toggle("Pinned to top", isOn: $pinned)
                        .padding(.top, 5)

                    SaveButtonView(text: "Save", action: {
                        if(isListToUpdate) {
                            updateList()
                        } else {
                            saveNewList()
                        }
                        isListToUpdate ? vm.changeFormViewState(to: .closeUpdateList) : vm.changeFormViewState(to: .closeAddList)
                    })
                    .padding(.top, 10)

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
            .alert(isPresented: $errorShowing) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
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
