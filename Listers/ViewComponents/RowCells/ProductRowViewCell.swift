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

    @State var product : DMProduct

    var actionEditProduct: () -> Void
    var isEditAvailable : Bool = false

    //MARK: - INITIALIZATION
    init(vm: CategoriesProductsViewModel, product: DMProduct, actionEditProduct: @escaping () -> Void, isEditAvailable: Bool = false) {
        self.vm = vm
        self.product = product
        self.actionEditProduct = actionEditProduct
        self.isEditAvailable = product.custom
    }

    //MARK: - FUNCTIONS
    func favProduct() {
        product.favorite.toggle()
        vm.setSelectedProduct(product)
        vm.saveCategoriesProductsUpdates()
        vm.setFavoriteCategory()
        print("Fav product \(product.name ?? "Unknown product")")
    }

    func addProductToList(){
        vm.setSelectedProduct(product)
        vm.addProductToList(product)
        vm.activeAlert = ProductAlertManager(type: .addedToList)
        print("Add product \(self.product.name ?? "Unknown product") to list \(String(describing: vm.selectedList))")
    }

    func addProductToListWithSelection() {
        vm.setSelectedProduct(product)
        vm.changeFormViewState(to: .openListSelectionToAddProduct)
        print("Add product \(self.product.name ?? "Unknown product") to list with selection")
    }

    func editProduct() {
        actionEditProduct()
        vm.setSelectedProduct(product)
        print("Edit product \(self.product.name ?? "Unknown product")")
    }

    func duplicateAndEditProduct() {
        let newProductId: Int = vm.duplicate(product: product)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let newProduct = vm.getProductById(newProductId)
            if let newProduct = newProduct {
                vm.setSelectedProduct(newProduct)
                vm.changeFormViewState(to: .openUpdateProduct)
                print("Duplicate product \(self.product.name ?? "Unknown product") and edit")
            } else {
                print("Error duplicating product \(self.product.name ?? "Unknown product")")
            }
        }
    }

    func confirmationToRemoveProductFromLibrary() {
        vm.setSelectedProduct(product)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            vm.activeAlert = ProductAlertManager(type: .confirmRemove)
        }
        print("Confirmation to remove product \(self.product.name ?? "Unknown product") from library")
    }

    func removeProductFromLibrary() {
        vm.selectedProduct?.active = false
        vm.selectedProduct?.selected = false
        vm.saveCategoriesProductsUpdates()
        vm.selectedProduct = nil
        print("Remove product \(self.product.name ?? "Unknown product") from library")
    }

    //MARK: - BODY
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                Text(product.name ?? L10n.shared.localize("product_row_cellview_unknown"))
                    .fontWeight(product.selected ? .black : .regular)

                Spacer()

                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .opacity(product.favorite ? 1 : 0)

                Menu {
                    Button(L10n.shared.localize("product_row_cellview_add_current"), action: addProductToList)
                    Button(L10n.shared.localize("product_row_cellview_add_selection"), action: addProductToListWithSelection)
                    Button(product.favorite ? L10n.shared.localize("product_row_cellview_remove_fav") : L10n.shared.localize("product_row_cellview_add_fav"), action: favProduct)
                    if(isEditAvailable) { Button(L10n.shared.localize("product_row_cellview_edit"), action: editProduct) }
                    Button(L10n.shared.localize("product_row_cellview_duplicate_edit"), action: duplicateAndEditProduct)
                    Button(L10n.shared.localize("product_row_cellview_remove"), action: confirmationToRemoveProductFromLibrary)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .onTapGesture {
                    vm.setSelectedProduct(product)
                    vm.saveCategoriesProductsUpdates()
                }
            } //: HSTACK PRODUCT
            .contentShape(Rectangle())
        } //: VSTACK MAIN
        .frame(minHeight: 25, idealHeight: 25, maxHeight: 35)
        .background(Color.background)
        .onTapGesture {
            vm.setSelectedProduct(product)
            vm.saveCategoriesProductsUpdates()
        }
        .onTapGesture(count: 2) {
            favProduct()
        }
        .alert(
            vm.activeAlert?.type.title ?? "",
            isPresented: Binding<Bool>(
                get: { vm.activeAlert != nil },
                set: { if !$0 { vm.activeAlert = nil } }
            ),
            presenting: vm.activeAlert,
            actions: { alert in
                switch alert.type {
                    case .addedToList, .edited:
                        Button(L10n.shared.localize("product_row_cellview_ok"), role: .cancel) {
                            vm.activeAlert = nil
                        }
                    case .confirmRemove:
                        Button(L10n.shared.localize("product_row_cellview_remove"), role: .destructive) {
                            removeProductFromLibrary()
                        }
                        Button(L10n.shared.localize("product_row_cellview_cancel"), role: .cancel) {
                            vm.activeAlert = nil
                        }
                }
            },
            message: { alert in
                switch alert.type {
                    case .addedToList:
                        Text(L10n.shared.localize("product_row_cellview_added_current", args: [(vm.selectedProduct?.name ?? ""), (vm.selectedList?.name ?? "")]))
                    case .edited:
                        Text(L10n.shared.localize("product_row_cellview_edited", args: vm.selectedProduct?.name ?? ""))
                    case .confirmRemove:
                        Text(L10n.shared.localize("product_row_cellview_confirm_remove", args: vm.selectedProduct?.name ?? ""))
                }
            }
        )
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
    newProduct.notes = "notes for product \(productId)"
    newProduct.categoryId = Int16(1)
    newProduct.active = true
    newProduct.favorite = true

    return newProduct
}

//MARK: - PREVIEW
#Preview (traits: .sizeThatFitsLayout) {
    let previewVM = CategoriesProductsViewModel()
    ProductRowViewCell(vm: previewVM, product: getProductPreview(), actionEditProduct: {}, isEditAvailable: false)
}
#endif
