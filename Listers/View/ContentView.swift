//
//  ContentView.swift
//  Listers
//
//  Created by Edu Caubilla on 12/6/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject var persistenceManager : PersistenceManager

    @FetchRequest(
        entity: DMItem.entity(),
        sortDescriptors: [],
        animation: .default)
    var items: FetchedResults<DMItem>

    @State private var showingAddItemView : Bool = false

    var body: some View {
        NavigationStack {
            List(items) { item in
                Text(item.name ?? "Unknown")
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .navigationTitle(Text("Listers"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        showingAddItemView.toggle()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .background(Circle().fill(Color("ColorBase")))
                            .foregroundStyle(.gray)
                    } //: BUTTON
                }
            }
            .sheet(isPresented: $showingAddItemView) {
                AddItemView()
            }
        }
    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = DMItem(context: viewContext)
//            newItem.timestamp = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
}

//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
