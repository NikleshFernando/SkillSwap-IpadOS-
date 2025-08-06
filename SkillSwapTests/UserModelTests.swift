//
//  UserModelTests.swift
//  SkillSwapTests
//
//  Created by Niklesh Fernando on 2025-05-04.
//

import XCTest
@testable import SkillSwap


final class UserModelTests: XCTestCase {
    func testInitialsFromFullName() {
        let user = User(id: "123", fullname: "Niklesh Fernando", email: "test@test.com")
        XCTAssertEqual(user.initials, "FN", "Expected initials to be 'FN'")
    }

    func testInitialsFallbackWhenNameEmpty() {
        let user = User(id: "123", fullname: "", email: "test@test.com")
        XCTAssertEqual(user.initials, "", "Expected initials to be empty")
    }
}
