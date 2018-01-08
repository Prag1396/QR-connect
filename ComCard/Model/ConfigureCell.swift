//
//  ConfigureCell.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/3/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class ConfigureCell: UITableViewCell {

    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var creditCardLabel: UILabel!
    @IBOutlet weak var passportNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateUI(user: User) {
        fullnameLabel.text = user.fullName
        phoneNumberLabel.text = user.phoneNumber
        creditCardLabel.text = user.cardNumber
        passportNumberLabel.text = user.passportNumber
        print(user.passportNumber)

    }

}
