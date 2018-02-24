//
//  CustomAlert+Ext.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/23/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import Foundation
import PCLBlurEffectAlert

extension PCLBlurEffectAlertController {
    
    func configureAlert(alert: PCLBlurEffectAlertController) {
        alert.configure(titleFont: UIFont(name: "Avenir Next", size: 18)!)
        alert.configure(titleColor: UIColor(red: 255/255, green: 117/255, blue: 117/255, alpha: 1.0))
        alert.configure(messageFont: UIFont(name: "Avenir Next", size: 15)!)
        alert.configure(messageColor: UIColor.white)
        alert.configure(textFieldsViewBackgroundColor: UIColor.lightText)
        alert.configure(textFieldBorderColor: UIColor.lightGray)
        alert.configure(cornerRadius: 15)
        alert.configure(buttonFont: [:], buttonTextColor: [.default:UIColor.white], buttonDisableTextColor: [:])
    }
}
