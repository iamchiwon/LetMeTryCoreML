//
//  EmotionService.swift
//  DailyLog
//
//  Created by Chiwon Song on 10/2/23.
//

import CoreML
import Foundation
import NaturalLanguage

class EmotionService {
    private let predictor: NLModel?

    init() {
        if let model = try? EmotionMeter(configuration: MLModelConfiguration()) {
            predictor = try? NLModel(mlModel: model.model)
        } else {
            predictor = nil
        }
    }

    func evaluate(text: String) -> Emotion {
        guard let predictor = predictor else { return .normal }
        guard let label = predictor.predictedLabel(for: text) else { return .normal }

        let result = predictor.predictedLabelHypotheses(for: text, maximumCount: 2)
        let value = result[label] ?? 0.5

        if label == "positive" {
            if value > 0.8 { return .happy }
            return .good
        }

        if label == "negative" {
            if value > 0.8 { return .sad }
            return .bad
        }

        return .normal
    }
}
