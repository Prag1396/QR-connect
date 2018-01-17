//
//  AlertViewController+image.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/10/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

extension UIAlertController {
    func addImage(image: UIImage) {

        var rescaledImage = image.scaleUIImageToSize(image: image, size: CGSize(width: 120, height: 120))
        let padding: CGFloat = 5
        let left: CGFloat = -self.view.frame.size.width/2 + rescaledImage.size.width + padding
        rescaledImage = rescaledImage.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: left, bottom: 0, right: 0))
        let imgAction = UIAlertAction(title: "", style: .default, handler: nil)
        imgAction.isEnabled = false
        imgAction.setValue(rescaledImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        self.addAction(imgAction)
    }
}
