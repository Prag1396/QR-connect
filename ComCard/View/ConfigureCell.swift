//
//  ConfigureCell.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/3/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class ConfigureCell: UITableViewCell {

    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateUI(user: User) {
        emailLabel.text = user.email
        phoneNumberLabel.text = user.phoneNumber

    }

}
