//
//  ReaderService.swift
//  BigEye
//
//  Created by Chiwon Song on 10/3/23.
//

import Foundation
import Observation
import Vision
import VisionKit

@Observable
class ReaderService {
    var processing = false
    var recognized: String?
    var message: String?

    func recognaizeText(image: UIImage) {
        recognized = nil
        message = nil
        processing = true

        guard let Image = image.cgImage else {
            recognized = nil
            message = "이미지 로딩 실패"
            processing = false
            return
        }

        Task {
            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard let result = request.results as? [VNRecognizedTextObservation],
                      error == nil else { return }

                let text = result.compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")

                self?.recognized = text
                self?.message = nil
                self?.processing = false
            }

            request.revision = VNRecognizeTextRequestRevision3
            request.recognitionLanguages = ["ko-KR"]
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            do {
                try VNImageRequestHandler(cgImage: Image, options: [:])
                    .perform([request])
            } catch {
                recognized = nil
                message = "글자 분석 실패"
                processing = false
            }
        }
    }
}
