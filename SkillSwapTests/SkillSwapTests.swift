//
//  SkillSwapTests.swift
//  SkillSwapTests
//
//  Created by Niklesh Fernando on 2025-04-19.
//

//import XCTest
//@testable import SkillSwap
//import Firebase
//
//final class SkillSwapTests: XCTestCase {
//
//    override func setUp() {
//        super.setUp()
//        FirebaseApp.configure()
//    }
//
//    func testFetchOffersReturnsResults() {
//        let expectation = XCTestExpectation(description: "Fetch offers from Firestore")
//
//        let db = Firestore.firestore()
//        db.collection("offers").getDocuments { snapshot, error in
//            XCTAssertNil(error, "Error should be nil")
//            XCTAssertNotNil(snapshot, "Snapshot should not be nil")
//            XCTAssertGreaterThan(snapshot?.documents.count ?? 0, 0, "Should return at least one offer")
//            expectation.fulfill()
//        }
//
//        wait(for: [expectation], timeout: 5.0)
//    }
//
//    func testOfferModelInit() {
//        let data: [String: Any] = [
//            "userID": "test123",
//            "wantToLearn": "SwiftUI",
//            "description": "I'll teach Firebase",
//            "offeredSkillID": "skill456",
//            "status": "pending"
//        ]
//        let doc = MockDocument(data: data, id: "offerABC")
//
//        let offer = Offer(document: doc)
//        XCTAssertNotNil(offer)
//        XCTAssertEqual(offer?.wantToLearn, "SwiftUI")
//    }
//}

