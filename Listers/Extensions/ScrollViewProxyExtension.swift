//
//  ScrollViewProxyExtension.swift
//  Listers
//
//  Created by Edu Caubilla on 30/7/25.
//

import SwiftUI

extension ScrollViewProxy: ScrollViewProxyProtocol {
}

/// As ScrollViewProxy is a struct and cannot be used for inheritance,
/// creating a protocol that copies the struct content and then extending
/// the original struct, the protocol can be passed as param and accessed for testing.
public protocol ScrollViewProxyProtocol {
    func scrollTo<ID>(_ id: ID, anchor: UnitPoint?) where ID : Hashable
}
