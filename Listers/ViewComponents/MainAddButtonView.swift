//
//  MainAddButtonView.swift
//  Listers
//
//  Created by Edu Caubilla on 20/6/25.
//

import SwiftUI

struct MainAddButtonView: View {

    var addButtonLabel: String = "Add"
    var addButtonIcon: String = "plus"
    var addButtonAction: () -> Void = {}

    var body: some View {
        Button(addButtonLabel, systemImage: addButtonIcon) {
            addButtonAction()
        }
        .foregroundStyle(.secondaryText)
        .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .font(.system(size: 22, weight: .semibold))
        .background(
            Capsule()
                .fill(Color.mediumBlue)
        )
        .padding(15)
//        .background(
//            Capsule()
//                .fill(LinearGradient(colors: [.mediumBlue, .lightBlue], startPoint: .top, endPoint: .bottom))
//            )
        .shadow(color: .darkBlue.opacity(0.2), radius: 1, x: 0.5, y: 0.5)
    }
}

#Preview (traits: .sizeThatFitsLayout) {
    MainAddButtonView()
}
