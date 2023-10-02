//
//  ImageColoriser
//
//  Created by Maksym Shcheglov.
//  Copyright © 2021 Maksym Shcheglov. All rights reserved.
//

import UIKit

extension UIImage {

    func scaled(with dimension: CGFloat) -> UIImage {
        let width = self.size.width
        let height = self.size.height
        let aspectWidth = dimension / width
        let aspectHeight = dimension / height
        let scaleFactor = max(aspectWidth, aspectHeight)
        let size = CGSize(width: CGFloat(round(width * scaleFactor)), height: CGFloat(round(height * scaleFactor)))

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func resizedImage(with size: CGSize) -> UIImage? {
        guard let image = cgImage else { return nil }

        if (image.colorSpace?.model == .rgb) {
            let bytesPerPixel = 4;
            let bytesPerRow = bytesPerPixel * Int(size.width);
            let bitsPerComponent = 8;
            let context = CGContext(data: nil,
                                    width: Int(size.width),
                                    height: Int(size.height),
                                    bitsPerComponent: bitsPerComponent,
                                    bytesPerRow: bytesPerRow,
                                    space: image.colorSpace!,
                                    bitmapInfo: image.bitmapInfo.rawValue)
            context?.interpolationQuality = .high
            context?.draw(image, in: CGRect(origin: .zero, size: size))

            guard let scaledImage = context?.makeImage() else { return nil }

            return UIImage(cgImage: scaledImage)
        } else if (image.colorSpace?.model == .monochrome) {
            let context = CGContext(data: nil,
                                    width: Int(size.width),
                                    height: Int(size.height),
                                    bitsPerComponent: image.bitsPerComponent,
                                    bytesPerRow: Int(size.width),
                                    space: image.colorSpace!,
                                    bitmapInfo: image.bitmapInfo.rawValue)
            context?.interpolationQuality = .high
            context?.draw(image, in: CGRect(origin: .zero, size: size))

            guard let scaledImage = context?.makeImage() else { return nil }

            return UIImage(cgImage: scaledImage)
        } else {
            assertionFailure("The colorspace is not supported yet!")
            return nil
        }
    }
}
