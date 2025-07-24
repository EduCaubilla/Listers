//
//  ListsView.swift
//  Listers
//
//  Created by Edu Caubilla on 25/6/25.
//

import SwiftUI
import CoreData

struct ListsView: View {
    //MARK: - PROPERTIES
    @EnvironmentObject var router: NavigationRouter
    @ObservedObject var vm: MainItemsListsViewModel

    @State private var showingDeleteWarning: Bool = false

    private var deleteWarningTitle: String = "Delete List"
    private var deleteWarningMessage: String = "Delete List"
    private var addListLabel : String = "Add List"
    private var addIcon : String = "plus"

    private var viewTitle : String = "My Lists"

    //MARK: - INITIALIZER
    init(vm: MainItemsListsViewModel) {
        self.vm = vm
    }

    //MARK: - FUNCTIONS
    private func editList(_ list: DMList) {
        setListSelected(list)
        vm.changeFormViewState(to: .openUpdateList)
    }

    private func setListSelected(_ list: DMList) {
        vm.updateSelectedList(list)
    }

    //MARK: - BODY
    var body: some View {
        VStack {
            List {
                if vm.isListsEmpty {
                    EmptyView()
                } else {
                    ForEach(Array(vm.lists.enumerated()), id: \.1) { index, list in
                        ListRowCellView(
                            vm: vm,
                            selectedList: list,
                            listItems: vm.fetchItemsForList(list),
                            actionEditList: {editList(list)}
                        )
                        .padding(.bottom, -10)
                        .listRowSeparator(index == 0 ? .hidden : .visible, edges: .top)
                        .listRowBackground(Color.clear)
                        .onTapGesture {
                            vm.updateSelectedList(list)
                            print(vm.selectedList!)

                            withTransaction(Transaction(animation: nil)) {
                                router.navigateTo(.main)
                            }
                        }
                    } //: LOOP
                }
            } //: LIST
            .listStyle(.plain)
            .navigationTitle(Text(viewTitle))
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom, content: {
                MainAddButtonView(
                    addButtonLabel: addListLabel,
                    addButtonIcon: addIcon,
                    addButtonAction: {vm.changeFormViewState(to: .openAddList)}
                )
            })
            .toolbar {
                toolbarContentView(router: router, route: .lists)
            } //: TOOLBAR
            .scrollContentBackground(.hidden)
            .background(Color.background)
            .gesture(DragGesture(minimumDistance: 30, coordinateSpace: .global)
            .onChanged { value in
                if vm.lists.isEmpty { return }

                guard value.startLocation.x < 100,
                      value.translation.width > 50 else {
                    return
                }

                router.navigateTo(.main)
            })
        } //: VSTACK MAIN
        .sheet(isPresented: $vm.showingAddListView) {
            FormListView(vm: vm)
                .padding(.top, 20)
                .presentationDetents([.height(320)])
                .presentationBackground(Color.background)
        }
        .sheet(isPresented: $vm.showingUpdateListView) {
            FormListView(vm: vm, list: vm.selectedList)
                .padding(.top, 20)
                .presentationDetents([.height(320)])
                .presentationBackground(Color.background)
        }
        .onAppear {
            vm.loadSettings()
            vm.currentScreen = .lists
        }
    } //: VIEW BODY
} //: VIEW MAIN

#if DEBUG
//MARK: - PREVIEW
#Preview {
    NavigationStack{
        ListsView(vm: MainItemsListsViewModel())
            .environmentObject(NavigationRouter())
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}

#Preview("Mocked Data List") {
/*    let previewVM = MainItemsListsViewModel(persistenceManager: PersistenceManager(context: PersistenceController.previewListItems.container.viewContext)) */
    let previewVM = MainItemsListsViewModel()

    NavigationStack{
        ListsView(vm: previewVM)
            .environmentObject(NavigationRouter())
            .environment(\.managedObjectContext, PersistenceController.previewListItems.container.viewContext)
    }
}

#endif
