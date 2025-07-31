//
//  ItemListCellView.swift
//  Listers
//
//  Created by Edu Caubilla on 20/6/25.
//

import SwiftUI

struct ItemRowCellView: View {
    //MARK: - PROPERTIES
    @ObservedObject var vm: MainItemsListsViewModel

    @ObservedObject var item: DMItem

    var actionEditItem: () -> Void
    var isEditAvailable : Bool = true

    var currentScreen : NavRoute = .main

    private var deleteLabel : String = L10n.shared.localize("item_row_cellview_delete")
    private var deleteIcon : String = "trash"
    private var addFavLabel : String = L10n.shared.localize("item_row_cellview_add_fav")
    private var addFavIcon : String = "star.fill"
    private var removeFavLabel : String = L10n.shared.localize("item_row_cellview_remove_fav")
    private var removeFavIcon : String = "star"
    private var editLabel : String = L10n.shared.localize("item_row_cellview_edit")
    private var editIcon : String = "square.and.pencil"

    private var color: Color {
        switch item.priority ?? Priority.normal.rawValue {
            case Priority.normal.rawValue:
                return .clear
            case Priority.high.rawValue:
                return .yellow
            case Priority.veryHigh.rawValue:
                return .red
            default:
                return .clear
        }
    }

    //MARK: - INITIALIZER
    init(vm: MainItemsListsViewModel, item: DMItem, actionEditItem: @escaping () -> Void, isEditAvailable: Bool = true, screen: NavRoute = .main) {
        self.vm = vm
        self.item = item
        self.actionEditItem = actionEditItem
        self.isEditAvailable = isEditAvailable
        self.currentScreen = screen
    }

    //MARK: - FUNCTIONS
    private func favItem() {
        item.favorite.toggle()
        vm.saveItemListsChanges()
    }

    private func deleteItem() {
        vm.delete(item)
    }

    private func saveItem() {
        vm.saveItemListsChanges()
        print("Item saved: \(item.name ?? "")")
    }

    private func checkListCompleted() {
        vm.checkListCompletedStatus()
    }

    private func updateItemOnCheckboxToggle() {
        saveItem()
        checkListCompleted()
    }

    //MARK: - BODY
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0){
                HStack(alignment: .center, spacing: 5) {
                    // COLOR MARK FOR PRIORITY
                    Rectangle()
                        .frame(width: 4, height: 30)
                        .foregroundStyle(color)

                    //COMPLETION TOGGLE
                    Toggle("", isOn: Binding(
                        get: { item.completed },
                        set: { item.completed = $0 }
                    ))
                    .onChange(of: item.completed, { oldValue, newValue in
                        updateItemOnCheckboxToggle()
                    })
                    .toggleStyle(CustomCheckboxStyle())
                    .foregroundStyle(.darkBlue)
                    .accessibilityIdentifier("complete_item_button")

                    //TEXT, DATE & COMMENT
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name ?? L10n.shared.localize("item_row_cellview_unknown"))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.darkBlue)
                            .lineLimit(2)
                            .strikethrough(item.completed ? true : false)

                        if vm.isItemEndDateVisible {
                            Text(item.endDate ?? Date.now, style: .date)
                                .font(.system(size: 14, weight: .light))
                                .foregroundStyle(.lightBlue)
                        }

                        if vm.isItemDescriptionVisible &&
                           !(item.notes == nil) &&
                           !item.notes!.isEmpty {
                            Text(item.notes ?? "")
                                .font(.system(size: 15, weight: .light))
                                .foregroundStyle(.gray.opacity(0.7))
                                .lineLimit(3)
                        }
                    } //: VSTACK
                    .padding(.leading, 5)

                    Spacer(minLength: 0)

                    //QUANTITY
                    if vm.isItemQuantityVisible {
                        Text("\(item.quantity.trimmedString) \(L10n.shared.localize("unit_count"))")
                            .foregroundStyle(.lightBlue)
                            .padding(3)
                    }
                } //: HSTACK
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                if isEditAvailable {
                    Button(action: {
                        deleteItem()
                    }) {
                        Label(deleteLabel, systemImage: deleteIcon)
                            .labelStyle(.iconOnly)
                    }
                    .tint(.red)
                }
            }
            .swipeActions(edge: .leading) {
                if isEditAvailable {
                    Button(action: {
                        favItem()
                    }) {
                        if item.favorite {
                            Label(removeFavLabel, systemImage: addFavIcon)
                                .labelStyle(.iconOnly)
                        } else {
                            Label(addFavLabel, systemImage: removeFavIcon)
                                .labelStyle(.iconOnly)
                        }
                    }
                    .tint(item.favorite ? .yellow : .gray)
                    .accessibilityIdentifier(item.favorite ? "remove_fav_button" : "add_fav_button")

                    Button(action: {
                        actionEditItem()
                    }) {
                        Label(editLabel, systemImage: editIcon)
                            .labelStyle(.iconOnly)
                    }
                    .tint(.mediumBlue)
                    .accessibilityIdentifier("edit_item_button")
                }
            }
        } //: VSTACK MAIN
    }
}

#if DEBUG
private func getItemPreview() -> DMItem {
    @Environment(\.managedObjectContext) var viewContext
    let itemNumber = Int.random(in: 0..<10)

    let newItem = DMItem(context: viewContext)
    newItem.id = UUID()
    newItem.name = "Item \(itemNumber)"
    newItem.notes = "This is item \(itemNumber)."
    newItem.quantity = Double.random(in: 0...10)
    newItem.creationDate = Date.now
    newItem.endDate = Date.now
    newItem.favorite = false
    newItem.completed = Bool.random()

    return newItem
}


//MARK: - PREVIEW
#Preview (traits: .sizeThatFitsLayout) {
    ItemRowCellView(vm: MainItemsListsViewModel(), item: getItemPreview(), actionEditItem: {})
}
#endif
