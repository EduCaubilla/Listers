//
//  ListsToAddProductView.swift
//  Listers
//
//  Created by Edu Caubilla on 15/7/25.
//

import SwiftUI

struct ListsToAddProductView: View {
    //MARK: - PROPERTIES
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: MainItemsListsViewModel

    var itemToAdd: DMProduct?

    @State private var itemsCount : Int = 0

    @State private var itemAddedToSelectedList: Bool = false

    private var addItemToListLabel: String = "Add Product"
    private var addItemToListIcon: String = "custom.checklist.square.plus"

    private var addToListViewTitle: String {
        vm.lists.isEmpty ? "" : "Add \(itemToAdd?.name ?? "product") to list"
    }

    //MARK: - INITIALIZATION
    init(vm: MainItemsListsViewModel, itemToAdd: DMProduct?) {
        self.vm = vm
        self.itemToAdd = itemToAdd
    }

    //MARK: - FUNCTIONS
    private func updateSelectedList(_ list: DMList) {
        vm.updateSelectedList(list)
    }

    private func addItemToSelectedList() {
        vm.addItemToList(
            name: itemToAdd?.name ?? "Product",
            description: itemToAdd?.notes,
            quantity: 0,
            favorite: false,
            priority: .normal,
            completed: false,
            selected: false,
            creationDate: Date.now,
            endDate: Date.now,
            image: "",
            link: "",
            listId: vm.selectedList?.id
        )

        print("Added item: \(itemToAdd?.name ?? "product") to selected list: \(vm.selectedListName)")

        itemAddedToSelectedList = true
    }

    private func closeCurrentForm() {
        dismiss()
    }

    //MARK: - BODY
    var body: some View {
        NavigationStack {
            if vm.lists.isEmpty {
                VStack(alignment: .center, spacing: 10) {
                    Text("There are no lists yet. \nYou must create one before adding a product.")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(.darkBlue)
                } //: VSTACK
                .background(Color.background)
            }

            List{
                ForEach(vm.lists) { list in
                    HStack(alignment: .center, spacing: 5) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(list.name ?? "")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.darkBlue)

                            Text("^[\(list.items?.count ?? 0) Article](inflect: true)")
                                .font(.subheadline)
                                .foregroundStyle(.lightBlue)
                        } //: VSTACK

                        Spacer()

                        Text(list.creationDate ?? Date.now, style: .date)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.trailing)
                            .foregroundStyle(.lightBlue)
                    } //: HSTACK
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.lightBlue, lineWidth: list.selected ? 3 : 1)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        updateSelectedList(list)
                        print("\(list.name ?? "") tapped")
                    }
                } //: LOOP
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } //: LIST
            .listStyle(.plain)
            .listRowSpacing(-10)
            .onAppear {
                vm.loadLists()
            }
            .navigationTitle(Text(addToListViewTitle))
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(
                edge: .bottom,
                content: {
                    if !vm.lists.isEmpty {
                        MainAddButtonView(
                            addButtonLabel: addItemToListLabel,
                            addButtonIcon: addItemToListIcon,
                            addButtonAction: {addItemToSelectedList()},
                            isSystemImage: false
                        )
                    }
                })
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        closeCurrentForm()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.darkBlue)
                    } //: DISSMISS BUTTON
                }
            } //: TOOLBAR
            .scrollContentBackground(.hidden)
            .background(Color.background)
            .alert("Item added successfully", isPresented: $itemAddedToSelectedList) {
                Button("Ok", role: .cancel) {
                    itemAddedToSelectedList = false
                    closeCurrentForm()
                }
            } message: {
                Text("Product \(itemToAdd?.name ?? "") added to selected list \(vm.selectedList?.name ?? "").")
            }

        } //: NAVIGATIONSTACK
    } //: MAIN VIEW
}

#if DEBUG
var itemToAddPreview: DMProduct {
    let newItem = DMProduct(context: PersistenceController.shared.container.viewContext)
    newItem.id = 1000
    newItem.name = "Test Item"
    newItem.active = true
    newItem.categoryId = 0
    newItem.favorite = false
    newItem.notes = "Description"
    newItem.custom = false
    newItem.selected = false
    return newItem
}

//MARK: - PREVIEW
#Preview {
        ListsToAddProductView(vm: MainItemsListsViewModel(), itemToAdd: itemToAddPreview)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

#Preview("Mocked Data List") {
//        let previewVM = MainItemsListsViewModel(persistenceManager: PersistenceManager(context: PersistenceController.previewListItems.container.viewContext))
        let previewVM = MainItemsListsViewModel()

        ListsToAddProductView(vm: previewVM, itemToAdd: itemToAddPreview)
            .environment(\.managedObjectContext, PersistenceController.previewListItems.container.viewContext)
}
#endif
