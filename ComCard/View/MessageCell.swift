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
            setUpNameAndProfileImage()
            if let seconds = messagetodisplay?.timeStamp.doubleValue {
                let timeStampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                self.timelabel.text = dateFormatter.string(from: timeStampDate as Date)
            }
            

        }
    }
    
    fileprivate func setUpNameAndProfileImage() {
        
        if let id = messagetodisplay?.charParnterID() {
            let ref = DataService.instance.REF_USERS.child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? NSDictionary {
                    self.name.text = dict["FirstName"] as? String
                    self.lastmessage.text = self.messagetodisplay?.messageText
                    self.profileImg.image = UIImage(named: "chatprofileImage")

                }
            
        }, withCancel: nil)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
