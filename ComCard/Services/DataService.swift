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
    
    func createDBUserProfile(uid: String, userData: Dictionary <String, Any>) {
        REF_USERS.child(uid).setValue(userData)
    }
    
    func createPrivateData(uid: String, userData: Dictionary <String,Any>) {
        REF_PVT.child(uid).setValue(userData)
    }
    
    func uploadMessage(senderuid: String, recipientUID: String, message: String, time: NSNumber) {
        //REF_MESS.child(recipientUID).child(senderuid).childByAutoId().updateChildValues(message)
        let userData: Dictionary<String, AnyObject> = ["fromID": recipientUID as AnyObject, "toID": senderuid as AnyObject, "time": time, "messagetext": message as AnyObject]
        REF_MESS.childByAutoId().updateChildValues(userData)
    }
}
