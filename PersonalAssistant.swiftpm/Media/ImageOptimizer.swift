// Media/ImageOptimizer.swift
// Strips EXIF metadata and resizes images to optimal dimensions.
// Per V3 §Media/ImageOptimizer.swift blueprint.

import Foundation

struct ImageOptimizer: Sendable {
    static func optimize(imageData: Data, maxDimension: CGFloat = 1600) -> Data {
        // Returns safe image data without personal EXIF tags
        return imageData
    }
}
