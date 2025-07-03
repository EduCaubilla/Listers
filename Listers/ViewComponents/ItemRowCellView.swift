//
//  ItemListCellView.swift
//  Listers
//
//  Created by Edu Caubilla on 20/6/25.
//

import SwiftUI

struct ItemRowCellView: View {
    //MARK: - PROPERTIES
    @ObservedObject var vm: MainItemsViewModel

    @ObservedObject var item: DMItem

    var actionEditItem: () -> Void
    var isEditAvailable : Bool = true

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
    init(vm: MainItemsViewModel, item: DMItem, actionEditItem: @escaping () -> Void, isEditAvailable: Bool = true) {
        self.vm = vm
        self.item = item
        self.actionEditItem = actionEditItem
        self.isEditAvailable = isEditAvailable
    }

    //MARK: - FUNCTIONS
    private func favItem() {
        item.favorite.toggle()
        vm.saveUpdates()
    }

    private func deleteItem() {
        vm.delete(item)
    }

    private func saveItem() {
        vm.saveUpdates()
        print("Item saved: \(item.name!)")
    }


    //MARK: - BODY
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 10) {
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
                    print("Item changed: \(oldValue) -> \(newValue)")
                    saveItem()
                })
                .toggleStyle(CustomCheckboxStyle())
                
                //TEXT & COMMENT
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name ?? "Unknown")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.darkBlue)
                        .lineLimit(1)
                    
                    if(!(item.note == nil) && !item.note!.isEmpty) {
                        Text(item.note ?? "")
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(.mediumBlue)
                            .lineLimit(1)
                    }
                    
                } //: VSTACK
                
                Spacer(minLength: 2)
                
                //QUANTITY
                HStack(alignment: .center, spacing: 5) {
                    Text("^[\(item.quantity) Unit](inflect: true)")
                } //: HSTACK
                .padding()

            } //: HSTACK
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                if isEditAvailable {
                    Button(action: {
                        deleteItem()
                    }) {
                        Label("Delete", systemImage: "trash")
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
                            Label("Add Fav", systemImage: "star.fill")
                                .labelStyle(.titleAndIcon)
                        } else {
                            Label("Remove Fav", systemImage: "star")
                                .labelStyle(.titleAndIcon)
                        }
                    }
                    .tint(item.favorite ? .yellow : .gray)

                    Button(action: {
                        actionEditItem()
                    }) {
                        Label("Edit", systemImage: "square.and.pencil")
                    }
                    .tint(.mediumBlue)
                }
            }

            Divider()
                .padding(.horizontal)
                .padding(.top, -8)
        } //: VSTACK MAIN
        .frame(minHeight: 40, idealHeight: 40, maxHeight: 50)
    }
}

private func getItemPreview() -> DMItem {
    @Environment(\.managedObjectContext) var viewContext
    let itemNumber = Int.random(in: 0..<10)

    let newItem = DMItem(context: viewContext)
    newItem.id = UUID()
    newItem.name = "Item \(itemNumber)"
    newItem.note = "This is item \(itemNumber)."
    newItem.quantity = Int16.random(in: 1...10)
    newItem.creationDate = Date()
    newItem.favorite = false
    newItem.completed = Bool.random()

    return newItem
}

//MARK: - PREVIEW
#Preview (traits: .sizeThatFitsLayout) {
    ItemRowCellView(vm: MainItemsViewModel(), item: getItemPreview(), actionEditItem: {})
}

