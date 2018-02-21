//
//  textViewStyle.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/21/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class textViewStyle: UITextView {

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            
        }
    }
    
    override func draw(_ rect: CGRect) {
        self.textContainerInset = UIEdgeInsetsMake(8, 3, 8, 3)
        
    }
    
    

}
