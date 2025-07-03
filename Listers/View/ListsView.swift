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
    @ObservedObject var vm: ContentViewViewModel

    @State var lists: [DMList] = []

    @State private var showingAddListView: Bool = false
    @State private var showingUpdateListView: Bool = false
    @State private var showingDeleteWarning: Bool = false

    var deleteWarningTitle: String = "Delete List"
    var deleteWarningMessage: String = "Delete List"

    var viewTitle : String = "My Lists"

    //MARK: - INITIALIZER
    init(vm: ContentViewViewModel) {
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
                ForEach(lists, id: \.self) { list in
                    ListRowCellView(
                        vm: vm,
                        selectedList: list,
                        listItems: vm.fetchItemsForList(list),
                        actionEditList: {editList(list)}
                    )
                    .onTapGesture {
                        print("tapped \(list.name ?? "Unknown")")
                        vm.updateSelectedList(list)
                        print(vm.selectedList!)

                        withTransaction(Transaction(animation: nil)) {
                            router.navigateTo(.main)
                        }
                    }
                }
                .listRowSeparator(.hidden)
            } //: LIST
            .listStyle(.plain)
            .listRowSpacing(-3)
            .navigationTitle(Text(viewTitle))
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom, content: {
                MainAddButtonView(label: "Add List", icon: "plus", action: {
                    showingAddListView.toggle()
                })
            })
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(alignment: .center, spacing: 10){
                        //TODO - Add Search in Categories
//                        Button(action: {
//                            //TODO Navigate to Search product
//                        }) {
//                            Image("custom.list.bullet.clipboard.badge.magnifyingglass")
//                                .resizable()
//                                .scaledToFit()
//                                .foregroundStyle(.darkBlue)
//                        }

                        Button(action: {
                            withTransaction(Transaction(animation: nil)) {
                                router.navigateTo(.settings)
                            }
                        }) {
                            Image(systemName: "gearshape")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.darkBlue)
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        withTransaction(Transaction(animation: nil)) {
                            router.navigateTo(.main)
                        }
                    }) {
                        Image("custom.checklist.square")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.darkBlue)
                    }
                }
            } //: TOOLBAR
        } //: NAVIGATION STACK
        .onReceive(vm.$lists) { _ in
            sortLists()
        }
        .sheet(isPresented: $showingAddListView) {
            AddUpdateListView(vm: vm)
                .padding(.top, 20)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingUpdateListView) {
            AddUpdateListView(vm: vm, list: vm.selectedList)
                .padding(.top, 20)
                .presentationDetents([.medium])
        }
    }
}

//MARK: - PREVIEW
#Preview {
    ListsView(vm: ContentViewViewModel())
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

#Preview("Mocked Data List") {
    ListsView(vm: ContentViewViewModel())
        .environment(\.managedObjectContext, PersistenceController.previewList.container.viewContext)
}
