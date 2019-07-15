//
//  Extension+UIImage.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/9.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

extension UIImage {
    /// 擷取當前image對象rect區域內的圖像
    func subImage(withRect rect: CGRect) -> UIImage? {
        guard let newCgImage = self.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: newCgImage)
    }
    
    /// 壓縮圖片至指定尺寸
    func rescaleImage(toSize size: CGSize) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
//        UIGraphicsBeginImageContext(size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 壓縮圖片至指定像素
    func rescaleImage(toPixel pixel: CGFloat) -> UIImage? {
        
        var newSize: CGSize
        
        if size.width <= pixel && size.height <= pixel {
            return self
        }
        let scale = size.width / size.height
        
        if size.width > size.height {
            newSize = CGSize(width: pixel, height: size.width / scale)
        } else {
            newSize = CGSize(width: size.height * scale, height: pixel)
        }
        
        return rescaleImage(toSize: newSize)
    }
    
    /// 指定大小生成一個平鋪的圖片
    func getTiledImage(withSize size: CGSize) -> UIImage? {
        let tempView = UIView(frame: CGRect(origin: .zero, size: size))
        tempView.backgroundColor = UIColor.init(patternImage: self)
        
//        UIGraphicsBeginImageContext(size, false, 0)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        tempView.layer.render(in: context)
        let bgImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return bgImage
    }
    
    /// 兩張圖生成一張圖
    func mergeImage(with image: UIImage) -> UIImage? {
        
        guard let firstCgImg = self.cgImage, let secondCgImg = image.cgImage else { return nil }
        
        let firstWidth = CGFloat(firstCgImg.width)
        let firstHeight = CGFloat(firstCgImg.height)
        
        let secondWidth = CGFloat(secondCgImg.width)
        let secondHeight = CGFloat(secondCgImg.height)
        
        let mergedSize = CGSize(width: max(firstWidth, secondWidth), height: max(firstHeight, secondHeight))
        

//        UIGraphicsBeginImageContext(mergedSize)
        UIGraphicsBeginImageContextWithOptions(mergedSize, false, 0)
        self.draw(in: CGRect(x: 0, y: 0, width: mergedSize.width , height: mergedSize.height ))
        image.draw(in: CGRect(x: 0, y: 0, width: mergedSize.width, height: mergedSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func mergeImageToSmall(with image: UIImage) -> UIImage? {
        
        guard let firstCgImg = self.cgImage, let secondCgImg = image.cgImage else { return nil }
        
        let firstWidth = CGFloat(firstCgImg.width)
        let firstHeight = CGFloat(firstCgImg.height)
        
        let secondWidth = CGFloat(secondCgImg.width)
        let secondHeight = CGFloat(secondCgImg.height)
        
        let mergedSize = CGSize(width: min(firstWidth, secondWidth), height: min(firstHeight, secondHeight))
        
        
        UIGraphicsBeginImageContext(mergedSize)
        self.draw(in: CGRect(x: 0, y: 0, width: mergedSize.width, height: mergedSize.height))
        image.draw(in: CGRect(x: 0, y: 0, width: mergedSize.width, height: mergedSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    /// UIView轉為UIImage(notice: static function)
    static func initFrom(_ view: UIView) -> UIImage? {
        
        let scale = UIScreen.main.scale
        
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // new calculate size from stack overflow /questions/7645454 ======================================================================
    static func scaledToSize(size: CGSize, withImage image: UIImage) -> UIImage? {
        if UIScreen.main.responds(to: #selector(getter: UIScreen.scale)) {
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        } else {
            UIGraphicsBeginImageContext(size)
        }
        
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    static func scaledToMaxWidth(_ width: CGFloat, maxHeight height: CGFloat, withImage image: UIImage) -> UIImage? {
        let oldWidth = image.size.width
        let oldHeight = image.size.height
        let scaleFactor = oldWidth > oldHeight ? width / oldWidth : height / oldHeight
    
        let newHeight = oldHeight * scaleFactor
        let newWidth = oldWidth * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        return UIImage.scaledToSize(size: newSize, withImage: image)
    }
    
}
