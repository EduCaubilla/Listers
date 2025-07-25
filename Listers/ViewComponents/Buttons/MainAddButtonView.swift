//
//  MainAddButtonView.swift
//  Listers
//
//  Created by Edu Caubilla on 20/6/25.
//

import SwiftUI

struct MainAddButtonView: View {

    var addButtonLabel: String = L10n.shared.localize("button_add")
    var addButtonIcon: String = "plus"
    var addButtonAction: () -> Void = {}
    var isSystemImage: Bool = true

    var body: some View {
        if isSystemImage {
            Button(addButtonLabel, systemImage: addButtonIcon) {
                addButtonAction()
            }
            .modifier(MainAddButtonModifier())
        } else {
            Button(addButtonLabel, image: ImageResource(name: addButtonIcon, bundle: Bundle.main)) {
                addButtonAction()
            }
            .modifier(MainAddButtonModifier())
        }
    }
}

#Preview (traits: .sizeThatFitsLayout) {
    MainAddButtonView(addButtonLabel: "Add", addButtonIcon: "plus", addButtonAction: {}, isSystemImage: true)
}
