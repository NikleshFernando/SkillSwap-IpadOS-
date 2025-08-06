//
//  OfferModelTest.swift
//  SkillSwapTests
//
//  Created by Niklesh Fernando on 2025-05-04.
//

import XCTest
@testable import SkillSwap

final class OfferModelTests: XCTestCase {

    func testOfferInitFromDictionary() {
        let mockData: [String: Any] = [
            "userID": "user1",
            "wantToLearn": "SwiftUI",
            "description": "Teach me SwiftUI",
            "offeredSkillID": "skill1",
            "status": "applied"
        ]

        let offer = Offer(from: mockData, id: "offer1")
        XCTAssertNotNil(offer)
        XCTAssertEqual(offer?.wantToLearn, "SwiftUI")
        XCTAssertEqual(offer?.status, "applied")
    }

    func testOfferInitFailsWithMissingFields() {
        let incompleteData: [String: Any] = [
            "userID": "user1",
            "description": "Missing wantToLearn and offeredSkillID"
        ]

        let offer = Offer(from: incompleteData, id: "offer1")
        XCTAssertNil(offer, "Offer init should fail with missing fields")
    }
}
