//
//  SearchBarCustomView.swift
//  Listers
//
//  Created by Edu Caubilla on 10/7/25.
//

import SwiftUI

struct SearchBarCustomView: View {
    //MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme

    @Binding var name: String
    @Binding var showSearchBar: Bool

    @State private var searchText: String = ""
    @FocusState private var isSearchBarFocused: Bool

    var productNameList: [String]

    var searchResults: [String] {
        return productNameList.filter { $0.lowercased().contains(searchText.lowercased()) && !$0.isEmpty }
    }

    var resultAction: () -> Void = { }

    //MARK: - BODY
    var body: some View {
        VStack {
            HStack {
                TextField(L10n.shared.localize("search_bar_view_search"), text: $searchText)
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
                    .fill(Color.clear)
                    .stroke(Color.gray.opacity(0.8), lineWidth: 0.4)
            )
            .padding(.horizontal)

            VStack(alignment: .center, spacing: 10) {
                if !searchResults.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(searchResults, id: \.self) { name in
                                Text(name)
                                    .padding(.vertical, 5)
                                    .padding(.leading, 10)
                                    .onTapGesture {
                                        self.name = name
                                        showSearchBar = false
                                        searchText = ""
                                        resultAction()
                                    }
                                Divider()
                            }
                        }
                    }
                    .frame(maxHeight: CGFloat(searchResults.count * 33), alignment: .leading)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                }
            } //: VSTACK - SEARCH RESULTS
        } //: HSTACK - MAIN
        .background(colorScheme == .light ? Color(UIColor.secondarySystemBackground) : .background)
    }
}



//MARK: - PREVIEW
#Preview {
    let mockedProductsNames: [String] = ["Apple", "Banana", "Orange", "Pineapple", "Strawberry"]

    SearchBarCustomView(name: .constant(""), showSearchBar: .constant(true), productNameList: mockedProductsNames)
}
