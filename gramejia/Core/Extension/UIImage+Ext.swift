//
//  UIImage+Ext.swift
//  gramejia
//
//  Created by Adam on 08/12/24.
//

import UIKit

extension UIImage {
    func compressTo(targetSizeKB: Double) -> Data? {
        let targetSizeBytes = targetSizeKB * 1024
        var compression: CGFloat = 1.0
        var imageData = self.jpegData(compressionQuality: compression)
        
        while let data = imageData, Double(data.count) > targetSizeBytes, compression > 0.01 {
            compression -= 0.1
            imageData = self.jpegData(compressionQuality: compression)
        }
        
        if let data = imageData, Double(data.count) > targetSizeBytes {
            
            let newSize = self.scaleImageToLessThan(targetSizeBytes: targetSizeBytes, initialCompression: compression)
            let resizedImage = self.resizeImage(targetSize: newSize)
            imageData = resizedImage.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }
    
    private func resizeImage(targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    private func scaleImageToLessThan(targetSizeBytes: Double, initialCompression: CGFloat) -> CGSize {
        var currentSize = self.size
        var scaleFactor: CGFloat = 0.9
        
        while let data = self.jpegData(compressionQuality: initialCompression), Double(data.count) > targetSizeBytes {
            currentSize = CGSize(width: currentSize.width * scaleFactor, height: currentSize.height * scaleFactor)
            scaleFactor -= 0.05
        }
        
        return currentSize
    }
}
