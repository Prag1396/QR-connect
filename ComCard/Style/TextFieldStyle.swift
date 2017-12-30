//
//  TextFieldStyle.swift
//  ComCard
//
//  Created by Pragun Sharma on 12/30/17.
//  Copyright © 2017 Pragun Sharma. All rights reserved.
//

import UIKit

class TextFieldStyle: UITextField {
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    override func draw(_ rect: CGRect) {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 4.0
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 0.5
    }
}


