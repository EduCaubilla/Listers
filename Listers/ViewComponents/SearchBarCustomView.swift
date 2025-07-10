//
//  SearchBarCustomView.swift
//  Listers
//
//  Created by Edu Caubilla on 10/7/25.
//

import SwiftUI

struct SearchBarCustomView: View {
    //MARK: - PROPERTIES

    @Binding var name: String
    @Binding var showSearchBar: Bool

    @State private var searchText: String = ""
    @FocusState private var isSearchBarFocused: Bool

    var productNameList: [String]

    var searchResults: [String] {
        return productNameList.filter { $0.lowercased().contains(searchText.lowercased()) }
    }

    //MARK: - BODY
    var body: some View {
        VStack {
            HStack {
                TextField("Search...", text: $searchText)
                    .autocorrectionDisabled(true)
                    .textFieldStyle(.plain)
                    .focused($isSearchBarFocused)
                    .onAppear {
                        isSearchBarFocused = true
                    }
                    .onSubmit {
                        self.name = searchText
                    }

                Spacer()

                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.gray)
                    .onTapGesture {
                        showSearchBar = false
                    }
            } //: HSTACK - SEARCHBAR
            .padding(.horizontal, 15)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.background)
                    .stroke(Color.backgroundGray, lineWidth: 0.5)
            )

            VStack {
                List(searchResults, id: \.self) { name in
                    Text(name)
                        .onTapGesture {
                            self.name = name
                            showSearchBar = false
                            searchText = ""
                        }
                        .listRowBackground(Color.background)
                } //: LIST - SEARCH OPTIONS
                .scrollIndicators(.visible)
                .scrollContentBackground(.hidden)
                .listStyle(.inset)
                .listRowSpacing(-5)
                .padding(EdgeInsets(top: -8, leading: -5, bottom: 10, trailing: 0))
            } //: VSTACK
        }
    }
}



//MARK: - PREVIEW
#Preview {
    let mockedProductsNames: [String] = ["Apple", "Banana", "Orange", "Pineapple", "Strawberry"]

    SearchBarCustomView(name: .constant(""), showSearchBar: .constant(true), productNameList: mockedProductsNames)
}
