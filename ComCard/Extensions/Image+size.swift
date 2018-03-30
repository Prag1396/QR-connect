//
//  Image+size.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/10/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

extension UIImage {
    
    func scaleUIImageToSize( image: UIImage, size: CGSize) -> UIImage {
        
        var scaledImageRect = CGRect.zero
        
        let aspectWidth:CGFloat = size.width / self.size.width
        let aspectHeight:CGFloat = size.height / self.size.height
        let aspectRatio:CGFloat = max(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        self.draw(in: scaledImageRect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    static func combineWith(image1: UIImage, image2: UIImage) -> UIImage {
        print(image2.size.width)
        print(image2.size.height)
        let size = CGSize(width: image1.size.width - 1.5, height: image1.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        image1.draw(in: CGRect(x:0 , y: 0, width: image1.size.width, height: image1.size.height))
        let scaledimage2 = image2.scaleUIImageToSize(image: image2, size: CGSize(width: 500, height: 500))
        image2.draw(in: CGRect(x: image1.size.width/6.8, y: image1.size.height/5, width: scaledimage2.size.width ,height: scaledimage2.size.height))
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func resizeImage(image: UIImage, newSize: CGSize) -> UIImage {
        let horizontalRatio = newSize.width / image.size.width
        let verticalRatio = newSize.height / image.size.height
        
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}
