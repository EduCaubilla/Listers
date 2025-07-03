//
//  MainAddButtonView.swift
//  Listers
//
//  Created by Edu Caubilla on 20/6/25.
//

import SwiftUI

struct MainAddButtonView: View {

    var label: String = "Add"
    var icon: String = "plus"
    var action: () -> Void = {}

    var body: some View {
        Button(label, systemImage: icon) {
            action()
        }
        .foregroundStyle(.white.opacity(0.8))
        .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .font(.system(size: 22, weight: .semibold))
        .background(
            Capsule()
                .fill(Color.darkBlue)
        )
        .padding(10)
        .background(
            Capsule()
                .fill(LinearGradient(colors: [.mediumBlue, .lightBlue], startPoint: .top, endPoint: .bottom))
            )
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0.5, y: 0.5)
    }
}

#Preview (traits: .sizeThatFitsLayout) {
    MainAddButtonView()
}
