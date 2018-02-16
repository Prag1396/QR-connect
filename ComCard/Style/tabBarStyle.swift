//
//  tabBarStyle.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/8/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class tabBarStyle: UITabBar {

    override func draw(_ rect: CGRect) {
        // Drawing code
        let backgroundImage = UIImageView(image: UIImage(named: "tabbarbg"))
        backgroundImage.frame = self.bounds
        self.addSubview(backgroundImage)
        self.sendSubview(toBack: backgroundImage)
        self.changeColor()

    }
    
    func changeColor() {
        
        for item in self.items! {
            item.badgeColor = UIColor.white
        }
    }
 

}
