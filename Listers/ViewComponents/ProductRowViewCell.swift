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

    @State private var showAddedToListAlert: Bool = false
    @State private var showAddedToSelectedListAlert: Bool = false
    @State private var showEditedAlert: Bool = false
    @State private var showRemovedFromLibraryAlert: Bool = false

    @State private var showingListSelectionToAddProductView: Bool = false

    //MARK: - INITIALIZATION
    init(vm: CategoriesProductsViewModel, product: DMProduct, actionEditProduct: @escaping () -> Void, isEditAvailable: Bool = false, selected: Bool = false) {
        self.vm = vm
        self.product = product
        self.actionEditProduct = actionEditProduct
        self.isEditAvailable = product.custom
        self.selected = selected
    }

    //MARK: - FUNCTIONS
    func favProduct() {
        product.favorite.toggle()
        vm.saveCategoriesProductsUpdates()
        favCategory()
    }

    func favCategory() {
        vm.setFavoriteCategory()
        vm.saveCategoriesProductsUpdates()
    }

    func addProductToList(){
        vm.addProductToList(product)
        showAddedToListAlert = true
        print("Add product \(self.product.name ?? "Unknown product") to list \(String(describing: vm.selectedList))")
    }

    func addProductToListWithSelection() {
        //TODO - Create sheet to select list and then save it

        showingListSelectionToAddProductView = true
        print("Add product \(self.product.name ?? "Unknown product") to list with selection")
    }

    func editProduct() {
        actionEditProduct()
        showEditedAlert = true
        print("Edit product \(self.product.name ?? "Unknown product")")
    }

    func duplicateAndEditProduct() {
        let newProductId: Int = vm.duplicate(product: product)
        let newProduct = vm.getProductById(newProductId)
        if let newProduct = newProduct {
            vm.selectedProduct = newProduct
            vm.showingEditProductView.toggle()
            print("Duplicate product \(self.product.name ?? "Unknown product") and edit")
        } else {
            print( "Error duplicating product \(self.product.name ?? "Unknown product")")
        }
    }

    func removeProductFromLibrary() {
        product.active = false
        vm.saveCategoriesProductsUpdates()
        showRemovedFromLibraryAlert = true
        vm.selectedProduct = nil
        print("Remove product \(self.product.name ?? "Unknown product") from library")
    }

    //MARK: - BODY
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                Text(product.name ?? "Product Unknown")
                    .fontWeight(selected ? .black : .regular)

                Spacer()

                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .opacity(product.favorite ? 1 : 0)

                Menu {
                    Button("Add to current list", action: addProductToList)
//                    Button("Add to list with selection", action: addProductToListWithSelection)
                    Button(product.favorite ? "Remove favorite " : "Add to favorites", action: favProduct)
                    Button("Edit product", action: editProduct)
                    Button("Duplicate and edit", action: duplicateAndEditProduct)
                    Button("Remove", action: removeProductFromLibrary)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            } //: HSTACK PRODUCT
            .contentShape(Rectangle())
        } //: VSTACK MAIN
        .frame(minHeight: 25, idealHeight: 25, maxHeight: 35)
        .background(Color.background)
        .onTapGesture(count: 2) {
            favProduct()
        }
        .alert("Adding Successful", isPresented: $showAddedToListAlert) {
            Button("Ok") {
                showAddedToListAlert = false
            }
        } message: {
                Text("Product \(product.name!) successfully added to current list")
        }
//        .alert("Adding Successful", isPresented: $showAddedToSelectedListAlert) {
//            Button("Ok") {
//                showAddedToSelectedListAlert = false
//            }
//        } message: {
//            Text("Product \(product.name!) successfully added to selected list \(selectedList.name ?? "")")
//        }
        .alert("Edit Successful", isPresented: $showEditedAlert) {
            Button("Ok") {
                showEditedAlert = false
            }
        } message: {
            Text("Product \(product.name!) successfully edited")
        }
        .alert("Removing Successful", isPresented: $showRemovedFromLibraryAlert) {
            Button("Ok") {
                showRemovedFromLibraryAlert = false
            }
        } message: {
            Text("Product \(product.name!) successfully removed from library")
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
