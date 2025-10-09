//
//  PhotoUtils.swift
//  Orhadi
//
//  Created by Ivory Svoboda . on 17/04/25.
//

import Foundation
import UIKit

func resizeImageAspectFill(_ data: Data, targetSize: CGSize) -> Data? {
    guard let image = UIImage(data: data) else { return nil }

    let originalSize = image.size
    let widthRatio = targetSize.width / originalSize.width
    let heightRatio = targetSize.height / originalSize.height
    
    let scale = max(widthRatio, heightRatio)
    let scaledSize = CGSize(width: originalSize.width * scale, height: originalSize.height * scale)

    let cropOrigin = CGPoint(
        x: (scaledSize.width - targetSize.width) / 2,
        y: (scaledSize.height - targetSize.height) / 2
    )

    let renderer = UIGraphicsImageRenderer(size: targetSize)
    let resizedImage = renderer.image { _ in
        image.draw(
            in: CGRect(origin: CGPoint(x: -cropOrigin.x, y: -cropOrigin.y), size: scaledSize)
        )
    }

    return resizedImage.jpegData(compressionQuality: 0.8)
}
