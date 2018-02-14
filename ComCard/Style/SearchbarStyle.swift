//
//  SearchbarStyle.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/13/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class SearchbarStyle: UISearchBar {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
        
    }
    
}
