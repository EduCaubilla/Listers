//
//  MockScrollViewProxy.swift
//  ListersTests
//
//  Created by Edu Caubilla on 30/7/25.
//

import SwiftUI
import XCTest
import Listers

class MockScrollViewProxy: ScrollViewProxyProtocol {
    var scrollToCalls: [(id: AnyHashable, anchor: UnitPoint?)] = []
    var scrollToCalled: Bool = false
    var lastScrolledId: Any?
    var scrollToExpectation: XCTestExpectation?

    func scrollTo<ID>(_ id: ID, anchor: UnitPoint? = nil) where ID : Hashable {
        scrollToCalls.append((id: AnyHashable(id), anchor: anchor))
        scrollToCalled = true
        lastScrolledId = id
        scrollToExpectation?.fulfill()
    }
}
