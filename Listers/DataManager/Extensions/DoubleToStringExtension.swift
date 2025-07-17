//
//  DoubleToStringExtension.swift
//  Listers
//
//  Created by Edu Caubilla on 17/7/25.
//

import SwiftUI

extension Double {
    var trimmedString: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}
