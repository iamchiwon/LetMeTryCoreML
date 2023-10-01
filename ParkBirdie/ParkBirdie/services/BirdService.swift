//
//  BirdService.swift
//  ParkBirdie
//
//  Created by Chiwon Song on 10/2/23.
//

import CoreML
import Observation
import UIKit
import Vision

struct Object {
    let label: String
    let confidence: VNConfidence
    let boundingBox: CGRect
}

@Observable
class BirdService {
    private let model = try! YOLOv3Tiny(configuration: MLModelConfiguration())

    var hasBird = false
    var detectedObjects: [Object] = []

    func predict(uiImage: UIImage?) {
        guard let coreMLModel = try? VNCoreMLModel(for: model.model) else { return }
        guard let image = uiImage,
              let pixelBuffer = image.toCVPixelBuffer() else {
            return
        }

        let request = VNCoreMLRequest(model: coreMLModel) { request, _ in
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                return
            }

            self.detectedObjects = results.map { result in
                guard let label = result.labels.first?.identifier else { return Object(label: "", confidence: VNConfidence.zero, boundingBox: .zero) }
                let confidence = result.labels.first?.confidence ?? 0.0
                let boundingBox = result.boundingBox
                let observation = Object(label: label, confidence: confidence, boundingBox: boundingBox)
                return observation
            }

            self.hasBird = self.detectedObjects.contains { $0.label == "bird" }
        }

        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)

        do {
            try requestHandler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
    }
}

private extension UIImage {
    func resizeTo(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    // https://www.hackingwithswift.com/whats-new-in-ios-11
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}
