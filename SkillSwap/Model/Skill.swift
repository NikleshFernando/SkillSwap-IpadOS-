//
//  Skill.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-04-20.
//

import Foundation
import FirebaseFirestore

struct Skill: Identifiable {
    var id: String
    var topic: String
    var description: String
    var videoURL: String?
    var pdfURL: String?

    init(id: String, topic: String, description: String, videoURL: String? = nil, pdfURL: String? = nil) {
        self.id = id
        self.topic = topic
        self.description = description
        self.videoURL = videoURL
        self.pdfURL = pdfURL
    }
    init?(document: DocumentSnapshot) {
        let data = document.data()
        guard let topic = data?["topic"] as? String,
              let description = data?["description"] as? String else {
            return nil
        }

        self.id = document.documentID
        self.topic = topic
        self.description = description
        self.videoURL = data?["videoURL"] as? String
        self.pdfURL = data?["pdfURL"] as? String
    }
}

