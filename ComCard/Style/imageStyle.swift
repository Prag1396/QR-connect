//
//  imageStyle.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/15/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class imageStyle: UIImageView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
 

}
