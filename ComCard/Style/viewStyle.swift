//
//  viewStyle.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/14/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class viewStyle: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }

}
