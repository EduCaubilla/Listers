//
//  AddUpdateListView.swift
//  Listers
//
//  Created by Edu Caubilla on 25/6/25.
//

import SwiftUI

struct AddUpdateListView: View {
    //MARK: - PROPERTIES
    @Environment(\.dismiss) var dismiss

    @ObservedObject var vm: MainItemsListsViewModel

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var creationDate: Date = Date.now
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
                creationDate: creationDate,
                endDate: Date.now,
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

            vm.saveUpdates()
        } else {
            print("List could not be updated.")
        }
    }

    //MARK: - BODY
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                //MARK: - NAME
                TextField("Name", text: $name)
                    .autocorrectionDisabled(true)
                    .focused($isFocused)

                Divider()

                //MARK: - DESCRIPTION
                TextField("Description", text: $description)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .autocorrectionDisabled(true)

                Divider()

                //MARK: - PINNED
                Toggle("Pinned to top", isOn: $pinned)
                    .padding(.top, 5)

                SaveButtonView(text: "Save", action: {
                    if(isListToUpdate) {
                        updateList()
                    } else {
                        saveNewList()
                    }
                    dismiss()
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
                    dismiss()
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
    } // VIEW
}

//MARK: - PREVIEW
#Preview {
    AddUpdateListView(vm: MainItemsListsViewModel())
}
