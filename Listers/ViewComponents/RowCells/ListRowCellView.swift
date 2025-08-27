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
    @ObservedObject var vm: MainItemsListsViewModel

    var selectedList: DMList

    var listItems: [DMItem]

    var actionEditList: () -> Void

    @State private var showingDeleteConfirmation: Bool = false
    @State private var showingChangeName: Bool = false
    @State private var nameToChange: String = ""

    private var deleteWarningTitle: String = L10n.shared.localize("list_row_cellview_delete_list")

    private var deleteLabel : String = L10n.shared.localize("list_row_cellview_delete")
    private var deleteIcon : String = "trash"
    private var addPinLabel : String = L10n.shared.localize("list_row_cellview_delete_add_pin")
    private var addPinIcon : String = "pin.fill"
    private var removePinLabel : String = L10n.shared.localize("list_row_cellview_delete_remove_pin")
    private var removePinIcon : String = "pin"
    private var editLabel : String = L10n.shared.localize("list_row_cellview_edit")
    private var editIcon : String = "square.and.pencil"
    private var cancelLabel : String = L10n.shared.localize("list_row_cellview_cancel")

    //MARK: - INITIALIZER
    init(vm: MainItemsListsViewModel, selectedList: DMList, listItems: [DMItem], actionEditList: @escaping () -> Void) {
        self.vm = vm
        self.selectedList = selectedList
        self.listItems = listItems
        self.actionEditList = actionEditList
    }

    //MARK: - FUNCTIONS
    private func pinList() {
        selectedList.pinned.toggle()
        saveUpdatedList()
    }

    private func deleteList() {
        vm.deleteList(selectedList)
        if vm.lists.count == 0 {
            vm.selectedList = nil
        }

        saveUpdatedList()
    }

    private func saveUpdatedList() {
        vm.saveItemListsChanges()
        vm.loadLists()
    }

    //MARK: - BODY
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 5) {
                HStack(alignment: .center, spacing: 2) {
                    VStack(alignment: .leading, spacing: 3) {
                        if showingChangeName {
                            TextField(L10n.shared.localize("list_row_cellview_list_title"), text: $nameToChange)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.darkBlue)
                                .onSubmit {
                                    selectedList.name = nameToChange
                                }
                        } else {
                            Text(selectedList.name ?? "")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.darkBlue)
                                .onTapGesture(count: 2) {
                                    showingChangeName = true
                                    nameToChange = selectedList.name ?? ""
                                }
                                .strikethrough(selectedList.completed)
                        }

                        if (listItems.count == 0){
                            Text("\(listItems.count) \(L10n.shared.localizeDict("unit_count", count: Int(listItems.count)))")
                                .font(.subheadline)
                                .foregroundStyle(.lightBlue)
                        } else {
                            Text("\(L10n.shared.localizeDict("unit_count", count: Int(listItems.count)))")
                            .font(.subheadline)
                            .foregroundStyle(.lightBlue)
                        }

                        if vm.isListDescriptionVisible &&
                            !(selectedList.notes == nil) &&
                            !selectedList.notes!.isEmpty {
                            Text(selectedList.notes ?? "")
                                .font(.system(size: 14, weight: .light))
                                .multilineTextAlignment(.leading)
                                .lineLimit(3)
                                .foregroundStyle(.gray.opacity(0.7))
                                .padding(.vertical, 0)
                        }
                    } //: VSTACK
                } //: HSTACK

                Spacer()

                if vm.isListEndDateVisible {
                    Text(selectedList.endDate ?? Date.now, style: .date)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.trailing)
                        .foregroundStyle(.lightBlue)
                }

                Image(systemName: selectedList.expanded ? "chevron.down" : "chevron.right")
                    .onTapGesture {
                        selectedList.expanded = !selectedList.expanded
                        vm.updateSelectedList(selectedList)
                    }
                    .foregroundStyle(.darkBlue)
            } //: HSTACK
            .padding(.top, selectedList.expanded ? -6 : 0) // To correct position when expanded row moves down 6pt.
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: {
                    showingDeleteConfirmation.toggle()
                }) {
                    Label(deleteLabel, systemImage: deleteIcon)
                        .labelStyle(.iconOnly)
                }
                .tint(.red)
            }
            .swipeActions(edge: .leading) {
                Button(action: {
                    withAnimation {
                        pinList()
                    }
                }) {
                    if selectedList.pinned {
                        Label(addPinLabel, systemImage: addPinIcon)
                            .labelStyle(.iconOnly)
                    } else {
                        Label(removePinLabel, systemImage: removePinIcon)
                            .labelStyle(.iconOnly)
                    }
                }
                .tint(selectedList.pinned ? .green : .gray)

                Button(action: {
                    actionEditList()
                }) {
                    Label(editLabel, systemImage: editIcon)
                        .labelStyle(.iconOnly)
                }
                .tint(.mediumBlue)
            }

            VStack(alignment: .leading, spacing: 0) {
                if(selectedList.expanded) {
                    //MARK: - List items
                    ForEach(Array(listItems.enumerated()), id: \.1) { index, item in
                        ItemRowCellView(
                            vm: vm,
                            item: item,
                            actionEditItem: actionEditList,
                            isEditAvailable: false,
                            screen: .lists
                        )
                        .padding(.top, 5)

                        if(index != listItems.count-1) {
                            Divider()
                                .padding(.top, 5)
                        }
                    } //: LOOP
                }
            } //: VSTACK
            .padding(.top, -5)
            .padding(.bottom, 8)
            .alert(deleteWarningTitle, isPresented: $showingDeleteConfirmation) {
                Button(deleteLabel, role: .destructive) {
                    deleteList()
                }
                Button(cancelLabel, role: .cancel) { }
            } message: {
                Text(L10n.shared.localize("list_row_cellview_remove_confirmation", args: selectedList.name ?? "selected list"))
            }
        } //: VSTACK MAIN
        .padding(.top, selectedList.expanded ? 6 : 0)
        .background(Color.background)
    } //: VIEW

}
#if DEBUG
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
            newItem.notes = "This is item \(itemNumber)."
            newItem.quantity = Int16.random(in: 0...10)
            newItem.creationDate = Date.now
            newItem.endDate = Date.now
            newItem.favorite = Bool.random()
            newItem.completed = Bool.random()
            newItem.listId = listId

            result.append(newItem)
        }

        return result
    }

    //MARK: - PREVIEW
    #Preview (traits: .sizeThatFitsLayout) {
        ListRowCellView(vm: MainItemsListsViewModel(), selectedList: getListPreview(), listItems: getListItemsPreview(), actionEditList: {})
    }
#endif
