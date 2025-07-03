//
//  ContentView.swift
//  Listers
//
//  Created by Edu Caubilla on 12/6/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    //MARK: - PROPERTIES
    @StateObject var vm : ContentViewViewModel
    @EnvironmentObject var router : NavigationRouter

    @State private var selectedItem: DMItem?

    @State private var showingAddItemView : Bool = false
    @State private var showingUpdateItemView : Bool = false
    @State private var showingAddListView : Bool = false

    @State private var showingSettingsView : Bool = false

    @State private var isAnimationRunning : Bool = false

    var selectedList: DMList?

    var selectedListName: String {
        vm.selectedList?.name ?? ""
    }

    //MARK: - INITIALIZER
    init(vm: ContentViewViewModel = ContentViewViewModel()) {
        _vm = StateObject(wrappedValue: vm)
    }

    //MARK: - FUNCTIONS
    private func editItem(_ item: DMItem) {
        setSelectedItem(item)
        showingUpdateItemView.toggle()
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
                        } //: LOOP
                        .ignoresSafeArea(.container, edges: .leading)
                    } //: LIST
                    .padding(.top)
                    .listStyle(.inset)
                    .navigationTitle(Text(selectedListName))
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarBackButtonHidden(true)
                    .safeAreaInset(edge: .bottom, content: {
                        MainAddButtonView(label: "Add Item", icon: "plus", action: {
                            showingAddItemView.toggle()
                        })
                    })
                } else {
                    VStack(alignment: .center, spacing: 20) {
                        Text("No items yet")
                            .font(.system(size: 30, weight: .light))
                        Image(systemName: "plus.circle")
                            .font(.system(size: 60, weight: .light))
                            .symbolEffect(.bounce, options: .speed(0.1).repeat(3))
                    }
                    .onAppear {
                        isAnimationRunning.toggle()
                    }
                    .onTapGesture {
                        showingAddListView.toggle()
                    }
                }
            } //: VSTACK
            .onAppear {
                vm.loadInitData()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(alignment: .center, spacing: 10){
                        //TODO - Add search in categories
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
                            router.navigateTo(.lists)
                        }
                    }) {
                        Image("custom.checklist.square.stack")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.darkBlue)
                    }
                }
            } //: TOOLBAR
        } //: NAVIGATION STACK
        .sheet(isPresented: $showingAddItemView, onDismiss: vm.loadItemsForSelectedList) {
            AddUpdateItemView(vm: vm)
                .padding(.top, 20)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingUpdateItemView, onDismiss: vm.loadItemsForSelectedList) {
            AddUpdateItemView(item: selectedItem, vm: vm)
        }
        .sheet(isPresented: $showingAddListView, onDismiss: vm.loadInitData) {
            AddUpdateListView(vm: vm)
                .padding(.top, 20)
                .presentationDetents([.medium])
        }
    } //: VIEW
}


//MARK: - PREVIEW
#Preview {
    ContentView(vm: ContentViewViewModel())
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

#Preview("Mocked") {
    ContentView(vm: ContentViewViewModel())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
