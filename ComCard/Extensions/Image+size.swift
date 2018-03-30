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
    
    func combineWith(image: UIImage) -> UIImage {
        let size = CGSize(width: self.size.width, height: self.size.height + image.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        self.draw(in: CGRect(x:0 , y: 0, width: size.width, height: self.size.height))
        image.draw(in: CGRect(x: 0, y: self.size.height, width: size.width,  height: image.size.height).insetBy(dx: size.width * 0.2, dy: size.height * 0.2))
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}
