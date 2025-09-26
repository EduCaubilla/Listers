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

    var addItemLabel: String = L10n.shared.localize("main_items_view_add")
    var addItemIcon: String = "plus"
    var noItemsLabel: String = L10n.shared.localize("main_items_view_no_items")
    var addItemIconCircle: String = "plus.circle"
    var completedListTitle: String = L10n.shared.localize("main_items_view_list_completed")

    //MARK: - INITIALIZER
    init(vm: MainItemsListsViewModel = MainItemsListsViewModel()) {
        _vm = StateObject(wrappedValue: vm)
    }

    //MARK: - FUNCTIONS
    private func editItem(_ item: DMItem) {
        setSelectedItem(item)
        vm.changeFormViewState(to: .openUpdateItem)
        print("Edit item: \(String(describing: selectedItem))")
    }

    private func setSelectedItem(_ item: DMItem) {
        selectedItem = item
    }

    private func goToListsAfterCompletion() {
        DispatchQueue.main.async {
            router.navigateTo(.lists)
            vm.changeFormViewState(to: .openAddList)
        }
    }

    private func onDismissModal() {
        if !vm.hasSelectedList {
            vm.loadInitData()
        } else {
            vm.loadItemsForSelectedList()
        }

        if vm.hasSelectedList && vm.itemsOfSelectedList.isEmpty {
            vm.changeFormViewState(to: .openAddItem)
        }
    }

    //MARK: - BODY
    var body: some View {
            VStack {
                VStack {
                    if vm.selectedList != nil {
                        List{
                            ForEach(Array(vm.itemsOfSelectedList.enumerated()), id: \.1) { index, item in
                                ItemRowCellView(
                                    vm: vm,
                                    item: item,
                                    actionEditItem: {editItem(item)}
                                )
                                .padding(.top, 5)
                                .listRowSeparator(index == 0 ? .hidden : .visible, edges: .top)
                                .listRowBackground(Color.clear)
                            } //: LOOP
                        } //: LIST
                        .padding(.top, 5)
                        .listStyle(.plain)
                        .navigationTitle(Text(selectedListName))
                        .navigationBarBackButtonHidden(true)
                        .navigationBarTitleDisplayMode(.inline)
                        .safeAreaInset(
                            edge: .bottom,
                            content: {
                                MainAddButtonView(
                                    addButtonLabel: addItemLabel,
                                    addButtonIcon: addItemIcon,
                                    addButtonAction: {vm.changeFormViewState(to: .openAddItem)}
                                )
                            })
                        .toolbar {
                            toolbarContentView(router: router, route: .main, action: {vm.shareList()})
                        } //: TOOLBAR
                        .scrollContentBackground(.hidden)
                        .background(Color.background)
                        .gesture(
                            DragGesture(minimumDistance: 100, coordinateSpace: .global)
                                .onChanged { value in
                                    if vm.lists.isEmpty { return }

                                    Task {
                                        print("Swipe value start location x: \(value.startLocation.x)")
                                        print("Swipe value location x: \(value.location.x)")
                                        print("Swipe value translation width: \(value.translation.width)")
                                    }

                                    guard value.startLocation.x > 300,
                                          value.translation.width < -80 else {
                                        Task { print("swipeFAILED") }
                                        return
                                    }

                                    Task { print("swipeOK") }
                                    router.navigateTo(.lists)
                                }
                        )
                        .accessibilityIdentifier("main_items_view")
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
                                    .foregroundStyle(.primaryText)
                            }
                            .onAppear {
                                isAnimationRunning.toggle()
                            }
                            .onTapGesture {
                                vm.changeFormViewState(to: .openAddList)
                            }
                        }
                        .navigationBarBackButtonHidden(true)
                        .accessibilityIdentifier("empty_state_view")
                    }
                } //: VSTACK
            } //: VSTACK MAIN
            .sheet(isPresented: $vm.showingAddItemView, onDismiss: onDismissModal) {
                FormItemView(vm: vm)
                    .padding(.top, 20)
                    .presentationDetents([.medium])
                    .presentationBackground(Color.background)
            }
            .sheet(isPresented: $vm.showingUpdateItemView, onDismiss: onDismissModal) {
                FormItemView(item: selectedItem, vm: vm)
                    .padding(.top, 20)
                    .presentationDetents([.medium])
                    .presentationBackground(Color.background)
            }
            .sheet(isPresented: $vm.showingAddListView, onDismiss: onDismissModal) {
                FormListView(vm: vm)
                    .padding(.top, 20)
                    .presentationDetents([.height(320)])
                    .presentationBackground(Color.background)
            }
            .sheet(isPresented: $vm.showShareSheet, content: {
                ShareSheet(items: [vm.sharedURL ?? ""])
            })
            .onAppear {
                DispatchQueue.main.async {
                    vm.loadInitData()
                    vm.loadProductNames()
                    vm.loadSettings()
                    vm.currentScreen = .main
                }
            }
            .alert(
                completedListTitle,
                isPresented: $vm.showCompletedListAlert,
                actions: {
                    Button(L10n.shared.localize("main_items_view_cancel")) {
                        vm.showCompletedListAlert = false
                    }
                    .accessibilityIdentifier("alert_main_items_view_cancel")

                    Button(L10n.shared.localize("main_items_view_ok")) {
                        goToListsAfterCompletion()

                    }
                    .accessibilityIdentifier("alert_main_items_view_ok")
                },
                message: {
                    Text(L10n.shared.localize("main_items_view_go_to_lists_new"))
                }
            )
    } //: VIEW
}

#if DEBUG
//MARK: - PREVIEW
#Preview {
    NavigationStack{
        MainItemsView(vm: MainItemsListsViewModel())
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(NavigationRouter())
    }
}

#Preview("Mocked") {
    let previewVM = MainItemsListsViewModel()

    NavigationStack{
        MainItemsView(vm: previewVM)
            .environmentObject(NavigationRouter())
            .environment(\.managedObjectContext, PersistenceController.previewListItems.container.viewContext)
    }
}
#endif
