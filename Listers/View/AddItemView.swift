//
//  AddItemView.swift
//  Listers
//
//  Created by Edu Caubilla on 13/6/25.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var persistenceManager: PersistenceManager

    @Environment(\.dismiss) var dismiss

    var priorities: [String] = Priority.allCases

    @State private var errorShowing : Bool = false
    @State private var errorTitle : String = ""
    @State private var errorMessage : String = ""

    @State private var name : String = ""
    @State private var description : String = ""
    @State private var endDate : Date = Date.now
    @State private var priority : Priority = .medium

    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    //MARK: - NAME
                    TextField("Add Name", text: $name)
                    
                    Divider()
                    
                    //MARK: - DESCRIPTION
                    TextField("Add description", text: $description)
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                    
                    Divider()
                    
                    //MARK: - DATE PICKER
                    DatePicker("End date", selection: $endDate)
                        .datePickerStyle(.compact)
                        .padding(.top, 10)
                    
                    //MARK: - PRIORITY
                    Picker("Priority", selection: $priority) {
                        Text("Low").tag(Priority.low)
                        Text("Medium").tag(Priority.medium)
                        Text("High").tag(Priority.high)
                    } //: PICKER
                    .pickerStyle(.segmented)
                    .padding(.top, 10)
                    
                    //MARK: - SAVE BUTTON
                    Button(action: {
                        if !name.isEmpty {
                            persistenceManager.name = name
                            persistenceManager.note = description
                            persistenceManager.endDate = endDate
                            persistenceManager.priority = priority.rawValue
                            
                            persistenceManager.saveItem(context: viewContext)
                        }
                        else {
                            errorShowing = true
                            errorTitle = "Invalid name"
                            errorMessage = "Please enter a name for your todo item."
                            return
                        }
                        dismiss()
                    }) {
                        Text("Save")
                            .font(.system(size: 20, weight: .medium))
                            .padding(10)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(.white)
                    } //: SAVE BUTTON
                    .padding(.top, 10)
                } //: VSTACK
                .padding(20)

                Spacer()
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.primary)
                    } //: DISSMISS BUTTON
                }
            }
            .alert(isPresented: $errorShowing) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        } //: NAVIGATION
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    AddItemView()
        .environmentObject(PersistenceManager())
}
