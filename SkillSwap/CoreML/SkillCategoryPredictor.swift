//
//  SkillCategoryPredictor.swift
//  SkillSwap
//
//  Created by Niklesh Fernando on 2025-06-28.
//

import Foundation
import CoreML

class SkillCategoryPredictor {
    static let shared = SkillCategoryPredictor()

    private let model: SkillCategoryPredictorModel

    private init() {
        self.model = try! SkillCategoryPredictorModel(configuration: MLModelConfiguration())
    }

    func predictCategory(for text: String) -> String {
        do {
            let prediction = try model.prediction(text: text)
            return prediction.label
        } catch {
            print("❌ Prediction failed: \(error.localizedDescription)")
            return ""
        }
    }
}



