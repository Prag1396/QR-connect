//
//  ContacCell.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/13/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class ContacCell: UITableViewCell {

    @IBOutlet weak var numberlabel: UILabel!
    @IBOutlet weak var fullnamelabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clear
    }

    func updateUI(contact: ContactStruct) {
        self.fullnamelabel.text = contact.givenName + " " + contact.familyName
        self.numberlabel.text = contact.phoneNumber

    }

}
