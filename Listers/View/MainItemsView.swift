//
//  ContentView.swift
//  Listers
//
//  Created by Edu Caubilla on 12/6/25.
//

import SwiftUI
import CoreData

@MainActor
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
    var noItemsLabel: String = "No lists yet.\nCreate one now."
    var addItemIconCircle: String = "plus.circle"
    var completedListTitle: String = "Congratulations!\nThe list is complete."

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
        DispatchQueue.main.async {
            withTransaction(Transaction(animation: nil)) {
                router.navigateTo(.lists)
            }
        }
    }

    private func onDismissModal() {
        if vm.selectedList == nil {
            vm.loadListsItemsData()
        } else {
            vm.loadItemsForSelectedList()
        }

        if vm.itemsOfSelectedList.isEmpty {
            vm.showingAddItemView = true
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
                                    .font(.system(size: 40, weight: .thin))
                                    .foregroundStyle(.primaryText)
                                    .multilineTextAlignment(.center)
                                Image(systemName: addItemIconCircle)
                                    .font(.system(size: 60, weight: .thin))
                                    .symbolEffect(.bounce, options: .speed(0.2).repeat(.periodic(25, delay: 1)))
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
                    vm.loadProductNames()
                }
                .toolbar {
                    toolbarContentView(router: router, route: .main)
                } //: TOOLBAR
                .gesture(DragGesture(minimumDistance: 30, coordinateSpace: .global)
                    .onChanged { value in
                        if vm.lists.isEmpty { return }

                        guard value.startLocation.x > 100,
                              value.translation.width > -50 else {
                            return
                        }

                        router.navigateTo(.lists)
                    })
            } //: VSTACK MAIN
            .sheet(isPresented: $vm.showingAddItemView, onDismiss: onDismissModal) {
                AddUpdateItemView(vm: vm)
                    .padding(.top, 20)
                    .presentationDetents([.medium])
                    .presentationBackground(Color.background)
            }
            .sheet(isPresented: $vm.showingUpdateItemView, onDismiss: onDismissModal) {
                AddUpdateItemView(item: selectedItem, vm: vm)
                    .padding(.top, 20)
                    .presentationDetents([.medium])
                    .presentationBackground(Color.background)
            }
            .sheet(isPresented: $vm.showingAddListView, onDismiss: onDismissModal) {
                AddUpdateListView(vm: vm)
                    .padding(.top, 20)
                    .presentationDetents([.height(260)])
                    .presentationBackground(Color.background)
            }
            .alert(
                completedListTitle,
                isPresented: $vm.showCompletedListMessage,
                actions: {
                    Button("Cancel") {
                        vm.showCompletedListMessage = false
                    }
                    Button("Ok") {
                        navigateToLists()
                    }
                },
                message: {
                    Text("Do you want to go to lists screen to create a new one?")
            })
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
