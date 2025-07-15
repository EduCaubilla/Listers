//
//  MainAddButtonModifier.swift
//  Listers
//
//  Created by Edu Caubilla on 15/7/25.
//

import SwiftUI

struct MainAddButtonModifier : ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
            .padding(.horizontal, 30)
            .padding(.vertical, 10)
            .font(.system(size: 20, weight: .regular, design: .default))
            .background(
                Capsule()
                    .fill(Color.mediumBlue)
            )
            .padding(15)
            .shadow(color: .darkBlue.opacity(0.2), radius: 1, x: 0.5, y: 0.5)
    }
}
