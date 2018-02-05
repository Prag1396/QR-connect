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
    
    
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right:5);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
}


