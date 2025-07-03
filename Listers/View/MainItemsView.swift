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
    @StateObject var vm : MainItemsViewModel
    @EnvironmentObject var router : NavigationRouter

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
    init(vm: @autoclosure @escaping () -> MainItemsViewModel = MainItemsViewModel()) {
        _vm = StateObject(wrappedValue: vm())
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
                    vm.loadInitData()
                }
                .toolbar {
                    toolbarContentView(router: router, route: .main)
                } //: TOOLBAR
            } //: VSTACK MAIN
            .sheet(isPresented: $vm.showingAddItemView, onDismiss: vm.loadItemsForSelectedList) {
                AddUpdateItemView(vm: vm)
                    .padding(.top, 20)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $vm.showingUpdateItemView, onDismiss: vm.loadItemsForSelectedList) {
                AddUpdateItemView(item: selectedItem, vm: vm)
            }
            .sheet(isPresented: $vm.showingAddListView, onDismiss: vm.loadInitData) {
                AddUpdateListView(vm: vm)
                    .padding(.top, 20)
                    .presentationDetents([.medium])
            }

    } //: VIEW
}


//MARK: - PREVIEW
#Preview {
    NavigationStack{
        MainItemsView(vm: MainItemsViewModel())
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(NavigationRouter())
    }
}

#Preview("Mocked") {
    NavigationStack{
        MainItemsView(vm: MainItemsViewModel())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(NavigationRouter())
    }
}
