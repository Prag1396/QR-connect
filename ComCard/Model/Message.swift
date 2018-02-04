//
//  Message.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/24/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

struct Message {
    
    var fromUID: String?
    var toID: String?
    var messagetext: String?
    var timeStamp: NSNumber?
    var imageURL: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    
    
    init(dictionary: [String: Any]) {
        self.fromUID = dictionary["fromID"] as? String
        self.toID = dictionary["toID"] as? String
        self.timeStamp = dictionary["time"] as? NSNumber
        self.messagetext = dictionary["messagetext"] as? String
        self.imageURL = dictionary["imageURL"] as? String
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
    
    }
    
    
    func charParnterID() -> String? {
        return fromUID == Auth.auth().currentUser?.uid ? toID : fromUID
    }
    
    
    
}
