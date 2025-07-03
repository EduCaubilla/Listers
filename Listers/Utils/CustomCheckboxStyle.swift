//
//  AddedStyles.swift
//  Listers
//
//  Created by Edu Caubilla on 20/6/25.
//

import SwiftUI

struct CustomCheckboxStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        return HStack {
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(configuration.isOn ? .green : .mediumBlue)
                .font(.system(size: 20, weight: .regular, design: .default))
        }
        .onTapGesture { configuration.isOn.toggle() }
    }
}
