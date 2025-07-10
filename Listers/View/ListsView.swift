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

    @State var lists: [DMList] = []

    @State private var showingAddListView: Bool = false
    @State private var showingUpdateListView: Bool = false
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
    private func sortLists() {
        if vm.lists.count > 0 {
            lists = vm.lists.sorted {
                ($0.pinned ? 0 : 1, $0.name?.lowercased() ?? "") <
                ($1.pinned ? 0 : 1, $1.name?.lowercased() ?? "")
            }
        }
    }

    private func editList(_ list: DMList) {
        setListSelected(list)
        showingUpdateListView.toggle()
    }

    private func setListSelected(_ list: DMList) {
        vm.updateSelectedList(list)
    }

    //MARK: - BODY
    var body: some View {
        VStack {
            List {
                if vm.isListEmpty {
                    EmptyView()
                } else {
                    ForEach(lists, id: \.self) { list in
                        ListRowCellView(
                            vm: vm,
                            selectedList: list,
                            listItems: vm.fetchItemsForList(list),
                            actionEditList: {editList(list)}
                        )
                        .onTapGesture {
                            vm.updateSelectedList(list)
                            print(vm.selectedList!)

                            withTransaction(Transaction(animation: nil)) {
                                router.navigateTo(.main)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            } //: LIST
            .listStyle(.plain)
            .listRowSpacing(-3)
            .navigationTitle(Text(viewTitle))
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom, content: {
                MainAddButtonView(
                    addButtonLabel: addListLabel,
                    addButtonIcon: addIcon,
                    addButtonAction: {showingAddListView.toggle()}
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
        .onReceive(vm.$lists) { _ in
            sortLists()
        }
        .sheet(isPresented: $showingAddListView) {
            AddUpdateListView(vm: vm)
                .padding(.top, 20)
                .presentationDetents([.height(220)])
                .presentationBackground(Color.background)
        }
        .sheet(isPresented: $showingUpdateListView) {
            AddUpdateListView(vm: vm, list: vm.selectedList)
                .padding(.top, 20)
                .presentationDetents([.height(220)])
                .presentationBackground(Color.background)
        }
    } //: VIEW BODY
} //: VIEW MAIN


//MARK: - PREVIEW
#Preview {
    NavigationStack{
        ListsView(vm: MainItemsListsViewModel())
            .environmentObject(NavigationRouter())
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}

#Preview("Mocked Data List") {
    let previewVM = MainItemsListsViewModel(persistenceManager: PersistenceManager(context: PersistenceController.previewListItems.container.viewContext))

    NavigationStack{
        ListsView(vm: previewVM)
            .environmentObject(NavigationRouter())
            .environment(\.managedObjectContext, PersistenceController.previewListItems.container.viewContext)
    }
}
