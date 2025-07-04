//
//  ListRowCellView.swift
//  Listers
//
//  Created by Edu Caubilla on 26/6/25.
//

import SwiftUI
import CoreData

struct ListRowCellView: View {
    //MARK: - PROPERTIES
    @ObservedObject var vm: MainItemsViewModel

    var selectedList: DMList

    var listItems: [DMItem]

    var actionEditList: () -> Void

    @State var isExpanded: Bool = true

    @State private var showingDeleteConfirmation: Bool = false
    private var deleteWarningTitle: String = "Delete List"
    private var deleteWarningMessage: String = "Are you sure you want to delete this list? You won't be able to restore it."

    private var deleteLabel : String = "Delete"
    private var deleteIcon : String = "trash"
    private var addPinLabel : String = "Add Pin"
    private var addPinIcon : String = "pin.fill"
    private var removePinLabel : String = "Remove Pin"
    private var removePinIcon : String = "pin"
    private var editLabel : String = "Edit"
    private var editIcon : String = "square.and.pencil"
    private var cancelLabel : String = "Cancel"

    //MARK: - INITIALIZER
    init(vm: MainItemsViewModel, selectedList: DMList, listItems: [DMItem], actionEditList: @escaping () -> Void) {
        self.vm = vm
        self.selectedList = selectedList
        self.listItems = listItems
        self.actionEditList = actionEditList
        self.isExpanded = selectedList.expanded
    }

    //MARK: - FUNCTIONS
    private func pinList() {
        selectedList.pinned.toggle()
        saveUpdatedList()
    }

    private func deleteList() {
        vm.delete(selectedList)
        saveUpdatedList()
    }

    private func updateExpanded() {
        isExpanded.toggle()
        selectedList.expanded.toggle()
        saveUpdatedList()
    }

    private func saveUpdatedList() {
        vm.saveUpdates()
        vm.fetchLists()
    }

    //MARK: - BODY
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 5) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(selectedList.name ?? "")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.darkBlue)
                    Text("^[\(listItems.count) Article](inflect: true)")
                        .font(.subheadline)
                        .foregroundStyle(.lightBlue)
                } //: VSTACK

                Spacer()

                Text(selectedList.creationDate ?? Date.now, style: .date)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.trailing)
                    .foregroundStyle(.mediumBlue)

                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .onTapGesture {
                        isExpanded.toggle()
                    }
                    .foregroundStyle(.darkBlue)
            } //: HSTACK
            .padding(.horizontal, 5)
            .padding(.vertical, -2)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: {
                    showingDeleteConfirmation.toggle()
                }) {
                    Label(deleteLabel, systemImage: deleteIcon)
                }
                .tint(.red)
            }
            .swipeActions(edge: .leading) {
                Button(action: {
                    pinList()
                }) {
                    if selectedList.pinned {
                        Label(addPinLabel, systemImage: addPinIcon)
                            .labelStyle(.titleAndIcon)
                    } else {
                        Label(removePinLabel, systemImage: removePinIcon)
                            .labelStyle(.titleAndIcon)
                    }
                }
                .tint(selectedList.pinned ? .green : .gray)

                Button(action: {
                    actionEditList()
                }) {
                    Label(editLabel, systemImage: editIcon)
                }
                .tint(.mediumBlue)
            }

            VStack(alignment: .center, spacing: 0) {
                if(isExpanded) {
                    //MARK: - List items
                    ForEach(listItems, id: \.self) { item in
                        ItemRowCellView(
                            vm: vm,
                            item: item,
                            actionEditItem: actionEditList,
                            isEditAvailable: false
                        )
                        .padding(.top, 2)
                    } //: LOOP
                    .listStyle(.plain)
                } else {
                    Divider()
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                }
            } //: VSTACK
            .padding(.top, 0)
            .alert(deleteWarningTitle, isPresented: $showingDeleteConfirmation, presenting: selectedList) { _ in
                Button(deleteLabel, role: .destructive) {
                    deleteList()
                }
                Button(cancelLabel, role: .cancel) { }
            } message: { list in
                Text("Are you sure you want to delete \"\(list.name ?? "this list")\"?")
            }

        } //: VSTACK MAIN
        .padding(.top, isExpanded ? 6 : 0)
    } //: VIEW

}

    private func getListPreview() -> DMList {
        @Environment(\.managedObjectContext) var viewContext

        let listId = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!

        let newList = DMList(context: viewContext)
        newList.id = listId
        newList.name = "Preview List 1"
        newList.creationDate = Date.now
        newList.pinned = false
        newList.notes = "This is a preview list 1."

        return newList
    }

    private func getListItemsPreview() -> [DMItem] {
        @Environment(\.managedObjectContext) var viewContext

        let listId = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!

        var result = [] as [DMItem]

        for _ in 0..<3 {
            let itemNumber = Int.random(in: 0..<10)

            let newItem = DMItem(context: viewContext)

            newItem.id = UUID()
            newItem.name = "Item \(itemNumber)"
            newItem.note = "This is item \(itemNumber)."
            newItem.quantity = Int16.random(in: 1...10)
            newItem.creationDate = Date.now
            newItem.favorite = Bool.random()
            newItem.completed = Bool.random()
            newItem.listId = listId

            result.append(newItem)
        }

        return result
    }

    //MARK: - PREVIEW
    #Preview (traits: .sizeThatFitsLayout) {
        ListRowCellView(vm: MainItemsViewModel(), selectedList: getListPreview(), listItems: getListItemsPreview(), actionEditList: {})
    }
