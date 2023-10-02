//
//  ColorService.swift
//  ColotFit
//
//  Created by Chiwon Song on 10/3/23.
//

import CoreML
import UIKit

private struct LAB {
    let l, a, b: [NSNumber]
}

private enum ColorizerError: Error {
    case preprocessFailure
    case postprocessFailure
}

struct Constants {
    static let inputDimension = 256
    static let inputSize = CGSize(width: inputDimension, height: inputDimension)
    static let coremlInputShape = [1, 1, NSNumber(value: Constants.inputDimension), NSNumber(value: Constants.inputDimension)]
}

class ColorService {
    private let model = try! Colorizer(configuration: MLModelConfiguration())

    func colorize(image inputImage: UIImage, completion: @escaping (Result<UIImage, Error>) -> Void) {
        Task {
            let result = self.colorize(image: inputImage)
            completion(result)
        }
    }

    private func colorize(image inputImage: UIImage) -> Result<UIImage, Error> {
        do {
            let inputImageLab = try preProcess(inputImage: inputImage)
            let input = try coloriserInput(from: inputImageLab)
            let output = try model.prediction(input: input)
            let outputImageLab = imageLab(from: output, inputImageLab: inputImageLab)
            let resultImage = try postProcess(outputLAB: outputImageLab, inputImage: inputImage)
            return .success(resultImage)
        } catch {
            return .failure(error)
        }
    }

    private func coloriserInput(from imageLab: LAB) throws -> ColorizerInput {
        let inputArray = try MLMultiArray(shape: Constants.coremlInputShape, dataType: MLMultiArrayDataType.float32)
        imageLab.l.enumerated().forEach({ idx, value in
            let inputIndex = [NSNumber(value: 0), NSNumber(value: 0), NSNumber(value: idx / Constants.inputDimension), NSNumber(value: idx % Constants.inputDimension)]
            inputArray[inputIndex] = value
        })
        return ColorizerInput(input1: inputArray)
    }

    private func imageLab(from colorizerOutput: ColorizerOutput, inputImageLab: LAB) -> LAB {
        var a = [NSNumber]()
        var b = [NSNumber]()
        for idx in 0 ..< Constants.inputDimension * Constants.inputDimension {
            let aIdx = [NSNumber(value: 0), NSNumber(value: 0), NSNumber(value: idx / Constants.inputDimension), NSNumber(value: idx % Constants.inputDimension)]
            let bIdx = [NSNumber(value: 0), NSNumber(value: 1), NSNumber(value: idx / Constants.inputDimension), NSNumber(value: idx % Constants.inputDimension)]
            a.append(NSNumber(value: colorizerOutput.var_518[aIdx].doubleValue))
            b.append(NSNumber(value: colorizerOutput.var_518[bIdx].doubleValue))
        }
        return LAB(l: inputImageLab.l, a: a, b: b)
    }

    // Pre-process input: resize
    private func preProcess(inputImage: UIImage) throws -> LAB {
        guard let lab = inputImage.resizedImage(with: Constants.inputSize)?.toLab() else {
            throw ColorizerError.preprocessFailure
        }
        return LAB(l: lab[0], a: lab[1], b: lab[2])
    }

    // Post-process output: resize to original & create a new one using Lightness component from the input image
    private func postProcess(outputLAB: LAB, inputImage: UIImage) throws -> UIImage {
        guard let resultImageLab = UIImage.image(from: [outputLAB.l, outputLAB.a, outputLAB.b], size: Constants.inputSize).resizedImage(with: inputImage.size)?.toLab(),
              let originalImageLab = inputImage.resizedImage(with: inputImage.size)?.toLab() else {
            throw ColorizerError.postprocessFailure
        }
        return UIImage.image(from: [originalImageLab[0], resultImageLab[1], resultImageLab[2]], size: inputImage.size)
    }
}
