//
//  SaveButtonView.swift
//  Listers
//
//  Created by Edu Caubilla on 20/6/25.
//

import SwiftUI

struct SaveButtonView: View {
    var text: String = L10n.shared.localize("button_save")
    var action: () -> Void = {}

    var body: some View {
        Button(action: {
            action()
        }) {
            Text(text)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.secondaryText)
                .padding(10)
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(.mediumBlue)
                .clipShape(
                    Capsule()
                )
        }
    }
}

#Preview {
    SaveButtonView()
}
