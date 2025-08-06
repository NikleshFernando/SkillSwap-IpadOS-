//
//  Offer.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-04-20.
//

import Foundation
import FirebaseFirestore

struct Offer: Identifiable {
    var id: String
    var userID: String
    var wantToLearn: String
    var description: String
    var offeredSkillID: String
    var userName: String  = "..."
    var status: String?
    var acceptedBy: String?
    var appliedBy: String?
    var appliedSkillID: String? 

    init?(document: DocumentSnapshot) {
        let data = document.data()
        guard
            let userID = data?["userID"] as? String,
            let wantToLearn = data?["wantToLearn"] as? String,
            let description = data?["description"] as? String,
            let offeredSkillID = data?["offeredSkillID"] as? String
        else {
            return nil
        }

        self.id = document.documentID
        self.userID = userID
        self.wantToLearn = wantToLearn
        self.description = description
        self.offeredSkillID = offeredSkillID
        self.status = data?["status"] as? String ?? "pending"
        self.acceptedBy = data?["acceptedBy"] as? String
        self.appliedBy = data?["appliedBy"] as? String
        self.appliedSkillID = data?["appliedSkillID"] as? String
        self.userName = "..."  // Can be filled when fetched if needed
    }

    init(id: String,
         userID: String,
         wantToLearn: String,
         description: String,
         offeredSkillID: String,
         userName: String,
         status: String? = "pending",
         acceptedBy: String? = nil,
         appliedBy: String? = nil,
         appliedSkillID: String? = nil) {

        self.id = id
        self.userID = userID
        self.wantToLearn = wantToLearn
        self.description = description
        self.offeredSkillID = offeredSkillID
        self.userName = userName
        self.status = status
        self.acceptedBy = acceptedBy
        self.appliedBy = appliedBy
        self.appliedSkillID = appliedSkillID
    }

    init?(from data: [String: Any], id: String) {
        guard let userID = data["userID"] as? String,
              let wantToLearn = data["wantToLearn"] as? String,
              let description = data["description"] as? String,
              let offeredSkillID = data["offeredSkillID"] as? String else {
            return nil
        }

        self.id = id
        self.userID = userID
        self.wantToLearn = wantToLearn
        self.description = description
        self.offeredSkillID = offeredSkillID
        self.userName = "Test"
        self.status = data["status"] as? String ?? "pending"
        self.acceptedBy = data["acceptedBy"] as? String
        self.appliedBy = data["appliedBy"] as? String
        self.appliedSkillID = data["appliedSkillID"] as? String
    }
}
