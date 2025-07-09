//
//  ContentView.swift
//  Listers
//
//  Created by Edu Caubilla on 12/6/25.
//

import SwiftUI
import CoreData

struct MainItemsView: View {
    //MARK: - PROPERTIES
    @EnvironmentObject var router : NavigationRouter

    @StateObject var vm : MainItemsListsViewModel

    @State private var selectedItem: DMItem?

    @State private var isAnimationRunning : Bool = false

    var selectedListName: String {
        vm.selectedList?.name ?? ""
    }

    var addItemLabel: String = "Add Item"
    var addItemIcon: String = "plus"
    var noItemsLabel: String = "No items yet"
    var addItemIconCircle: String = "plus.circle"

    //MARK: - INITIALIZER
    init(vm: MainItemsListsViewModel = MainItemsListsViewModel()) {
        _vm = StateObject(wrappedValue: vm)
    }

    //MARK: - FUNCTIONS
    private func editItem(_ item: DMItem) {
        setSelectedItem(item)
        vm.showingUpdateItemView = true
        print("Edit item: \(String(describing: selectedItem))")
    }

    private func setSelectedItem(_ item: DMItem) {
        selectedItem = item
    }

    private func navigateToLists() {
        withTransaction(Transaction(animation: nil)) {
            router.navigateTo(.lists)
        }
    }

    //MARK: - BODY
    var body: some View {
            VStack {
                VStack {
                    if vm.selectedList != nil {
                        List{
                            ForEach(vm.itemsOfSelectedList, id: \.self) { item in
                                ItemRowCellView(
                                    vm: vm,
                                    item: item,
                                    actionEditItem: {editItem(item)}
                                )
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            } //: LOOP
                        } //: LIST
                        .padding(.top)
                        .listStyle(.inset)
                        .navigationTitle(Text(selectedListName))
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(true)
                        .safeAreaInset(
                            edge: .bottom,
                            content: {
                                MainAddButtonView(
                                    addButtonLabel: addItemLabel,
                                    addButtonIcon: addItemIcon,
                                    addButtonAction: {vm.showingAddItemView.toggle()}
                                )
                            })
                        .scrollContentBackground(.hidden)
                        .background(Color.background)
                    } else {
                        ZStack {
                            Color.background
                                .ignoresSafeArea(edges: .all)
                            VStack(alignment: .center, spacing: 20) {
                                Text(noItemsLabel)
                                    .font(.system(size: 30, weight: .light))
                                    .foregroundStyle(.primaryText)
                                Image(systemName: addItemIconCircle)
                                    .font(.system(size: 60, weight: .light))
                                    .symbolEffect(.bounce, options: .speed(0.1).repeat(3))
                                    .foregroundStyle(.primaryText)
                            }
                            .onAppear {
                                isAnimationRunning.toggle()
                            }
                            .onTapGesture {
                                vm.showingAddListView.toggle()
                            }
                        }
                        .navigationBarBackButtonHidden(true)
                    }
                } //: VSTACK
                .onAppear {
                    vm.loadListsItemsData()
                }
                .toolbar {
                    toolbarContentView(router: router, route: .main)
                } //: TOOLBAR
                .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
                    .onChanged { value in
                        if vm.lists.isEmpty { return }

                        guard value.startLocation.x > 100,
                              value.translation.width > -60 else {
                            return
                        }

                        router.navigateTo(.lists)
                    })
            } //: VSTACK MAIN
            .sheet(isPresented: $vm.showingAddItemView, onDismiss: vm.loadItemsForSelectedList) {
                AddUpdateItemView(vm: vm)
                    .padding(.top, 20)
                    .presentationDetents([.medium])
                    .presentationBackground(Color.background)
            }
            .sheet(isPresented: $vm.showingUpdateItemView, onDismiss: vm.loadItemsForSelectedList) {
                AddUpdateItemView(item: selectedItem, vm: vm)
                    .padding(.top, 20)
                    .presentationDetents([.height(320)])
                    .presentationBackground(Color.background)
            }
            .sheet(isPresented: $vm.showingAddListView, onDismiss: {vm.loadListsItemsData()}) {
                AddUpdateListView(vm: vm)
                    .padding(.top, 20)
                    .presentationDetents([.height(220)])
                    .presentationBackground(Color.background)
            }

    } //: VIEW
}


//MARK: - PREVIEW
#Preview {
    NavigationStack{
        MainItemsView(vm: MainItemsListsViewModel())
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(NavigationRouter())
    }
}

#Preview("Mocked") {
    let previewVM = MainItemsListsViewModel(persistenceManager: PersistenceManager(context: PersistenceController.previewListItems.container.viewContext))

    NavigationStack{
        MainItemsView(vm: previewVM)
            .environmentObject(NavigationRouter())
            .environment(\.managedObjectContext, PersistenceController.previewListItems.container.viewContext)
    }
}
