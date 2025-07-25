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
            withTransaction(Transaction(animation: nil)) {
                router.navigateTo(.lists)

                vm.changeFormViewState(to: .openAddList)
            }
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
                        .padding(.top)
                        .listStyle(.inset)
                        .listRowSpacing(-5)
                        .navigationTitle(Text(selectedListName))
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(true)
                        .safeAreaInset(
                            edge: .bottom,
                            content: {
                                MainAddButtonView(
                                    addButtonLabel: addItemLabel,
                                    addButtonIcon: addItemIcon,
                                    addButtonAction: {vm.changeFormViewState(to: .openAddItem)}
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
                                vm.changeFormViewState(to: .openAddList)
                            }
                        }
                        .navigationBarBackButtonHidden(true)
                    }
                } //: VSTACK
                .onAppear {
                    vm.loadInitData()
                    vm.loadProductNames()
                    vm.loadSettings()
                    vm.currentScreen = .main
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
            .alert(
                completedListTitle,
                isPresented: $vm.showCompletedListAlert,
                actions: {
                    Button(L10n.shared.localize("main_items_view_cancel")) {
                        vm.showCompletedListAlert = false
                    }
                    Button(L10n.shared.localize("main_items_view_ok")) {
                        goToListsAfterCompletion()

                    }
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
