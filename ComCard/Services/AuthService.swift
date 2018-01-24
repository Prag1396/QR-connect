//
//  AuthService.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/1/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage


class AuthService: UIViewController {
    static let instance = AuthService()
    let defaults = UserDefaults.standard

    
    func sendCode(withPhoneNumber phoneNumber: String, messageSentComplete: @escaping(_ status: Bool, _ error: Error?) -> ()) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if error != nil {
                messageSentComplete(false, error)
            } else {
                        self.defaults.set(verificationID, forKey: "authVID")
                        messageSentComplete(true, nil)

                    }
            
                
            }
    }
    
    func auth(code: UITextField, authorizationComplete: @escaping(_ status: Bool, _ error: Error?) -> ()) {
        
        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "authVID")!, verificationCode: code.text!)
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                authorizationComplete(false, error)
            } else {
                    //Authorization successfull
                    authorizationComplete(true, nil)
                    }
            }
    }
    
        
    func registerUser(withEmail email: String, andPassword password: String, firstName: String, lastname: String, phonenumber: String, userCreationComplete: @escaping (_ uid: String?, _ status: Bool, _ error: Error?) -> ()) {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
               if error != nil {
                    userCreationComplete(nil, false, error)
               } else {
                let userData: Dictionary<String, String> = ["FirstName" :firstName, "lastName": lastname]
                let pvtData: Dictionary<String, String> = ["PhoneNumber": phonenumber, "Email": email]
                DataService.instance.createDBUserProfile(uid: (user?.uid)!, userData: userData)
                DataService.instance.createPrivateData(uid: (user?.uid)!, userData: pvtData)
                let provider = EmailAuthProvider.credential(withEmail: email, password: password)
                Auth.auth().currentUser?.link(with: provider, completion: { (user, error) in
                    if (error != nil) {
                        print(error.debugDescription)
                    } else {
                        print("Linked successfully")
                    }
                })
                userCreationComplete((user?.uid)!, true, nil)
                }
            }
    }
        
    func loginUser(withEmail email: String, andPassword password: String, loginComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error != nil {
                    loginComplete(false, error)
                    return
                }
                loginComplete(true, nil)
            }
    }
    
    
    func handleErrorCode(error: NSError, onCompleteErrorHandler: @escaping(_ errorMsg: String, _ data: AnyObject?)->()) {
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            switch (errorCode) {
            case .tooManyRequests: do {
                onCompleteErrorHandler("Too many requests from this device. Please try again later", nil)
                }
            case .userTokenExpired: do {
                onCompleteErrorHandler("Session has expired. Please try again", nil)
                }
            case .userDisabled: do {
                onCompleteErrorHandler("Your accunt has been disabled. Please contact the admin", nil)
                }
            case .invalidPhoneNumber: do {
                onCompleteErrorHandler("Invalid Phone number. Enter phone number again with country code", nil)
                }
            case .webNetworkRequestFailed: do {
                onCompleteErrorHandler("Network Error. Please try again later", nil)
                }
            case .networkError: do {
                onCompleteErrorHandler("Session Timed out. Please try again", nil)
                }
            case .wrongPassword: do {
                onCompleteErrorHandler("Invalid Passcode", nil)
                }
            case .invalidVerificationCode: do {
                onCompleteErrorHandler("Invalid Code. Please try again", nil)
                }
            case .credentialAlreadyInUse: do {
                onCompleteErrorHandler("Phone number already in use", nil)
                }
            default:
                onCompleteErrorHandler("Internal Error. Please try again.", nil)
            
            }
        }
    }
    
    func deleteUser(userID: String) {
        let userRef = DataService.instance.REF_USERS
        let privateRef = DataService.instance.REF_PVT
        userRef.child(userID).setValue(nil)
        privateRef.child(userID).setValue(nil)

        let imageRef = Storage.storage().reference(forURL: ImageURLStruct.imageURL)
        imageRef.delete { (error) in
            if (error != nil) {
                print(error.debugDescription)
            } else {
                print("Deleted successfully")
            }
        }
        
        Auth.auth().currentUser?.delete(completion: { (error) in
            if (error != nil) {
                print(error.debugDescription)
            } else {
                print("Deleted User Successfully")
            }
        })
        
    }

    
    func checkIfPhoneNumberExists(phoneNumber: String, checkComplete: @escaping(_ status: Bool, _ errmsg: String?)->()) {
        let userRef = DataService.instance.REF_BASE
        userRef.child("pvtdata").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value) { (dataSnapshot) in
            let array:NSArray = dataSnapshot.children.allObjects as NSArray
            for child in array {
                let snap = child as! DataSnapshot
                if let phonedowloaded = snap.value as? String {
                    if phonedowloaded == phoneNumber {
                        checkComplete(false, "Duplicate number exists")
                    } else {
                        checkComplete(true, nil)
                    }
                }
                
                
            }
           }

        }
}
