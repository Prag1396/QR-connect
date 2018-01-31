//
//  MessageCell.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/24/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class MessageCell: UITableViewCell {

    @IBOutlet weak var lastmessage: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var timelabel: UILabel!
    
    var messagetodisplay: Message? {
        didSet {
            let ref = DataService.instance.REF_USERS.child((self.messagetodisplay?.toID)!)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dict = snapshot.value as? NSDictionary {
                        if let name = dict["FirstName"] as? String {
                            let messagetosend = self.messagetodisplay?.messageText
                            let time = self.messagetodisplay?.timeStamp
                            self.updateUI(name: name, text: messagetosend!, time: time!)
                        }
                    }
  
        }, withCancel: nil)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateUI(name: String, text: String, time: NSNumber) {
        profileImg.image = UIImage(named: "chatprofile")
        self.name.text = name
        self.lastmessage.text = text
        
        let seconds = time.doubleValue
        let timeStampDate = NSDate(timeIntervalSince1970: seconds)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        self.timelabel.text = dateFormatter.string(from: timeStampDate as Date)
    }
    

}
