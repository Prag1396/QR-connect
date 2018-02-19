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
    private var _REF_ORDERSPLACED = DB_BASE.child("orders-placed")
    private var _REF_ORDERDETAILS = DB_BASE.child("order-details")
    
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
    
    var REF_ORDERSPLACED: DatabaseReference {
        return _REF_ORDERSPLACED
    }
    
    var REF_ORDERDETAILS: DatabaseReference {
        return _REF_ORDERDETAILS
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
    
    
    func placeorder(firstname: String, lastname: String, addressline1: String, addressline2: String, city: String, state: String, country: String, zipCode: String, quantity: String, onOrderComplete: @escaping(_ status: Bool, _ error: Error?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let orderRef = REF_ORDERSPLACED.childByAutoId()
        let orderOwnerData: Dictionary<String, String> = ["OrderOwner": uid]
        
        let orderData: Dictionary<String, AnyObject> = ["FirstName": firstname as AnyObject, "LastName": lastname as AnyObject, "addline1": addressline1 as AnyObject, "addline2": addressline2 as AnyObject, "city": city as AnyObject, "state": state as AnyObject, "country": country as AnyObject, "zipcode": zipCode as AnyObject, "Quantity": quantity as AnyObject]
        
        
        orderRef.updateChildValues(orderOwnerData) { (error, ref) in
            if error != nil {
                onOrderComplete(false, error)
                return
            }
            let orderId = orderRef.key
            let orderDetailsRef = self.REF_ORDERDETAILS.child(orderId)
            orderDetailsRef.updateChildValues(orderData, withCompletionBlock: { (error, ref) in
                if error != nil {
                    onOrderComplete(false, error)
                    return
                }
            })
            onOrderComplete(true, nil)
        }
            
        
    }
    
    
}
