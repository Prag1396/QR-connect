//
//  tabbaritemStyle.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/19/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class tabbaritemStyle: UITabBarItem {

    private let _orangeColor = UIColor(red: 255/255, green: 177/255, blue: 6/255, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: self._orangeColor], for: .selected)
  
    }

    
}
