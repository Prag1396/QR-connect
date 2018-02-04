//
//  DataService.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/1/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

let DB_BASE = Database.database().reference()

class DataService {
    static let instance = DataService()

    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_PVT = DB_BASE.child("pvtdata")
    private var _REF_MESS = DB_BASE.child("messages")
    private var _REF_USERMESSAGES = DB_BASE.child("user-messages")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_PVT: DatabaseReference {
        return _REF_PVT
    }
    
    var REF_MESS: DatabaseReference {
        return _REF_MESS
    }
    
    var REF_USERMESSAGES: DatabaseReference {
        return _REF_USERMESSAGES
    }
    
    func createDBUserProfile(uid: String, userData: Dictionary <String, Any>) {
        REF_USERS.child(uid).setValue(userData)
    }
    
    func createPrivateData(uid: String, userData: Dictionary <String,Any>) {
        REF_PVT.child(uid).setValue(userData)
    }
    
    func uploadMessage(senderuid: String, recipientUID: String, message: String, time: NSNumber) {
        
        let childRef = REF_MESS.childByAutoId()
        
        let userData: Dictionary<String, AnyObject> = ["fromID": senderuid as AnyObject, "toID": recipientUID as AnyObject, "time": time, "messagetext": message as AnyObject]

        childRef.updateChildValues(userData) { (error, ref) in
            if error != nil {
                print(error.debugDescription)
            } else {
                let userMessagesRef = DataService.instance.REF_USERMESSAGES.child(senderuid).child(recipientUID)
                let messageID = childRef.key
                userMessagesRef.updateChildValues([messageID: 1])
                
                let recipientUserMessagesRef = DataService.instance.REF_USERMESSAGES.child(recipientUID).child(senderuid)
                recipientUserMessagesRef.updateChildValues([messageID: 1])
            }
            
        }
    }
    
    func sendMessagewithImageURL(image: UIImage, imageURL: String, senderuid: String, recipientUID: String, time: NSNumber) {
        
        let childRef = REF_MESS.childByAutoId()
        
        let userData: Dictionary<String, AnyObject> = ["fromID": senderuid as AnyObject, "toID": recipientUID as AnyObject, "time": time, "imageURL": imageURL as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        
        childRef.updateChildValues(userData) { (error, ref) in
            if error != nil {
                print(error.debugDescription)
            } else {
                let userMessagesRef = DataService.instance.REF_USERMESSAGES.child(senderuid).child(recipientUID)
                let messageID = childRef.key
                userMessagesRef.updateChildValues([messageID: 1])
                
                let recipientUserMessagesRef = DataService.instance.REF_USERMESSAGES.child(recipientUID).child(senderuid)
                recipientUserMessagesRef.updateChildValues([messageID: 1])
            }
            
        }
        
        
    }
    
    
}
