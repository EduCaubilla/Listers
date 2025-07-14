//
//  ProductRowViewCell.swift
//  Listers
//
//  Created by Edu Caubilla on 7/7/25.
//

import SwiftUI

struct ProductRowViewCell: View {
    //MARK: - PROPERTIES
    @ObservedObject var vm: CategoriesProductsViewModel

    @ObservedObject var product : DMProduct

    var actionEditProduct: () -> Void
    var isEditAvailable : Bool = false

    private var selected : Bool = false

    private var deleteLabel : String = "Delete"
    private var deleteIcon : String = "trash"
    private var addFavLabel : String = "Add Favorite"
    private var addFavIcon : String = "star.fill"
    private var removeFavLabel : String = "Remove Favorite"
    private var removeFavIcon : String = "star"
    private var editLabel : String = "Edit"
    private var editIcon : String = "square.and.pencil"

    //MARK: - INITIALIZATION
    init(vm: CategoriesProductsViewModel, product: DMProduct, actionEditProduct: @escaping () -> Void, isEditAvailable: Bool = false, selected: Bool = false) {
        self.vm = vm
        self.product = product
        self.actionEditProduct = actionEditProduct
        self.isEditAvailable = product.custom
        self.selected = selected
    }

    //MARK: - FUNCTIONS
    func disableProduct() {
        product.active.toggle()
        vm.saveCategoriesProductsUpdates()
    }

    func favProduct() {
        product.favorite.toggle()
        vm.saveCategoriesProductsUpdates()
        favCategory()
    }

    func favCategory() {
        vm.setFavoriteCategory()
        vm.saveCategoriesProductsUpdates()
    }

    //MARK: - BODY
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                Text(product.name ?? "Product Unknown")
                    .fontWeight(selected ? .black : .regular)

                Spacer()

                if product.favorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .padding(.trailing, -8)
                }
            } //: HSTACK PRODUCT
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                if isEditAvailable {
                    Button(action: {
                        disableProduct()
                    }) {
                        Label(deleteLabel, systemImage: deleteIcon)
                    }
                    .tint(.red)
                }
            }
            .swipeActions(edge: .leading) {
                Button(action: {
                    favProduct()
                }) {
                    if product.favorite {
                        Label(addFavLabel, systemImage: addFavIcon)
                            .labelStyle(.iconOnly)
                    } else {
                        Label(removeFavLabel, systemImage: removeFavIcon)
                            .labelStyle(.iconOnly)
                    }
                }
                .tint(product.favorite ? .yellow : .gray)

                if isEditAvailable {
                    Button(action: {
                        actionEditProduct()
                    }) {
                        Label(editLabel, systemImage: editIcon)
                    }
                    .tint(.mediumBlue)
                }
            }
        } //: VSTACK MAIN
        .frame(minHeight: 25, idealHeight: 25, maxHeight: 35)
        .background(Color.background)
        .onTapGesture(count: 2) {
            favProduct()
        }
    } //: VIEW  
}

#if DEBUG
private func getProductPreview() -> DMProduct {
    @Environment(\.managedObjectContext) var viewContext
    let productId = Int.random(in: 1...100)

    let newProduct = DMProduct(context: viewContext)
    newProduct.uuid = UUID()
    newProduct.id = Int16(productId)
    newProduct.name = "Product \(productId)"
    newProduct.note = "Note for product \(productId)"
    newProduct.categoryId = Int16(1)
    newProduct.active = true
    newProduct.favorite = true

    return newProduct
}
#endif

//MARK: - PREVIEW
#Preview (traits: .sizeThatFitsLayout) {
    ProductRowViewCell(vm: CategoriesProductsViewModel(persistenceManager: PersistenceManager(context: PersistenceController.shared.container.viewContext)), product: getProductPreview(), actionEditProduct: {}, isEditAvailable: false)
}
