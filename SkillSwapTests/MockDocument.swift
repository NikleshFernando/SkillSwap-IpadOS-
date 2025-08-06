//
//  MockDocument.swift
//  SkillSwapTests
//
//  Created by Niklesh Fernando on 2025-04-21.
//

import FirebaseFirestore

class MockDocument: DocumentSnapshot {
    private let mockData: [String: Any]
    private let mockID: String

    override var documentID: String { mockID }

    override func data() -> [String: Any]? {
        return mockData
    }

//    init(data: [String: Any], id: String) {
//        self.mockData = data
//        self.mockID = id
//        // Warning: DocumentSnapshot is not directly subclassable in production,
//        // this is just for unit testing stubs. For cleaner approach, consider:
//        // Add a custom init to your Offer like: Offer(from dictionary: [String: Any])
//        super.init()
//    }
//    func testOfferModelInitWithMockData() {
//        let mockData: [String: Any] = [
//            "userID": "user_123",
//            "wantToLearn": "SwiftUI",
//            "description": "I'll teach Firebase",
//            "offeredSkillID": "skill_456",
//            "status": "pending"
//        ]
//
//        let offer = Offer(from: mockData, id: "mockOfferID")
//        XCTAssertNotNil(offer)
//        XCTAssertEqual(offer?.wantToLearn, "SwiftUI")
//    }
}

