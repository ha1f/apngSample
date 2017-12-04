//
//  UIImageExtension.swift
//  Musubi
//
//  Created by はるふ on 2016/11/10.
//  Copyright © 2016年 有村琢磨. All rights reserved.
//

import UIKit

extension UIImage {
    /// Get as CIImage
    /// If the UIImage is build from CGImage, ciImage is nil.
    /// https://developer.apple.com/documentation/uikit/uiimage/1624129-ciimage
    /// If so, we must build by CIImage(image:_).
    var safeCiImage: CIImage? {
        return self.ciImage ?? CIImage(image: self)
    }
    
    /// Get as CGImage
    /// If the UIImage is build from CIImage, cgImage is nil.
    /// https://developer.apple.com/documentation/uikit/uiimage/1624147-cgimage
    /// If so, we must build with CIContext
    var safeCgImage: CGImage? {
        if let cgImge = self.cgImage {
            return cgImge
        }
        if let ciImage = safeCiImage {
            let context = CIContext(options: nil)
            return context.createCGImage(ciImage, from: ciImage.extent)
        }
        return nil
    }
    
    /// 画像をリサイズ
    func getResizedImage(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// 画像を、比率維持したまま縮小（大きくすることはない）
    func getReductedImage(maxSize: CGSize) -> UIImage? {
        let scale = min((maxSize.width / self.size.width), (maxSize.height / self.size.height))
        if scale > 1.0 {
            return self.safeCgImage.map { UIImage(cgImage: $0) }
        }
        let newSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        return getResizedImage(size: newSize)
    }
    
    func getOrientaionNormalizedImage() -> UIImage? {
        if self.imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Create UIImage by drawing current image on colored context.
    ///
    /// - parameter color: Color of the background context
    ///
    /// - returns: The created image. Nil on error.
    func withSettingBackground(color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        guard let cgImage = safeCgImage else {
            return nil
        }
        let frame = CGRect(origin: .zero, size: size)
        context.clear(frame)
        context.setFillColor(color.cgColor)
        context.fill(frame)
        context.draw(cgImage, in: frame)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Create UIImage of black or transparent.
    /// CIImage-masking treats white as transparent, while CALayer-masking
    /// treats transparent as transparent.
    /// For this reason, we should make white of UIImage transparent to use
    /// the CIImage-masking image for CALayer-masking image.
    ///
    /// - parameter inverse: Invert transparent area or not
    ///
    /// - returns: The created image. Nil on error.
    func blacked(inverse: Bool = false) -> UIImage? {
        if inverse {
            guard let mask = UIImage.empty(size: size, color: .white)?.masked(with: self)?.withSettingBackground(color: .black) else {
                return nil
            }
            return UIImage.empty(size: size, color: .black)?.masked(with: mask)
        } else {
            return UIImage.empty(size: size, color: .black)?.masked(with: self)
        }
    }
    
    /// Create UIImage by masking current image with another image.
    /// Treat white as transparent.
    ///
    /// - parameter image: Image for masking
    ///
    /// - returns: The created image. Nil on error.
    func masked(with image: UIImage) -> UIImage? {
        guard let maskRef = image.safeCgImage,
            let ref = safeCgImage,
            let dataProvider = maskRef.dataProvider else {
                return nil
        }
        
        let mask = CGImage(maskWidth: maskRef.width,
                           height: maskRef.height,
                           bitsPerComponent: maskRef.bitsPerComponent,
                           bitsPerPixel: maskRef.bitsPerPixel,
                           bytesPerRow: maskRef.bytesPerRow,
                           provider: dataProvider,
                           decode: nil,
                           shouldInterpolate: false)
        return mask
            .flatMap { ref.masking($0) }
            .map { UIImage(cgImage: $0) }
    }
    
    func withPadding(_ inset: UIEdgeInsets) -> UIImage {
        let imageSize = self.size.withPadding(inset)
        let imageRect = CGRect(origin: .zero, size: imageSize)
        return UIGraphicsImageRenderer(size: imageSize).image { context in
            let imageRect = self.size.rectOfCenter(in: imageRect)
            self.draw(in: imageRect)
        }
    }
    
    /// Create UIImage filled with a color.
    ///
    /// - parameter size: Size of output image
    /// - parameter color: Color to fill
    ///
    /// - returns: The created image. Nil on error.
    static func empty(size: CGSize, color: UIColor = .clear) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let frame = CGRect(origin: .zero, size: size)
        context.clear(frame)
        context.setFillColor(color.cgColor)
        context.fill(frame)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Create UIImage of circle.
    ///
    /// - parameter size: Size of output image
    /// - parameter color: Color of the circle
    /// - parameter backgroundColor: Background color of the image
    ///
    /// - returns: The created image. Nil on error.
    static func circle(size: CGSize, color: UIColor, backgroundColor: UIColor = .clear) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let frame = CGRect(origin: .zero, size: size)
        context.clear(frame)
        
        // background
        context.setFillColor(backgroundColor.cgColor)
        context.fill(frame)
        
        // circle
        context.setFillColor(color.cgColor)
        context.setLineWidth(0)
        context.addEllipse(in: frame)
        context.fillPath()
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Create UIImage by drawing text
    ///
    /// - parameter text: string to draw
    /// - parameter fontSize: size of text
    ///
    /// - returns: The created image. Nil on error.
    static func fromText(text: String, fontSize: CGFloat = UIFont.systemFontSize, textColor: UIColor = .white) -> UIImage? {
        let attributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize),
            NSAttributedStringKey.foregroundColor: textColor,
            NSAttributedStringKey.paragraphStyle: NSMutableParagraphStyle.default
        ]
        let imageSize = (text as NSString).size(withAttributes: attributes)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.setTextDrawingMode(CGTextDrawingMode.fill)
        
        let textRect = CGRect(origin: .zero, size: imageSize)
        (text as NSString).draw(in: textRect, withAttributes: attributes)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
