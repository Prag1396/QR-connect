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
                    print("Phonenumber: \(String(describing: user?.phoneNumber))")
                    let userInfo = user?.providerData[0]
                    print("ProviderID: \(String(describing: userInfo?.providerID))")
                        
                    //Authorization successfull
                    authorizationComplete(true, nil)
                    }
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
    
    
    func checkIfPhoneNymbeExists(phoneNumber: String, checkComplete: @escaping(_ status: Bool, _ errmsg: String?)->()) {
        let userRef = DataService.instance.REF_BASE
        userRef.child("users").queryOrdered(byChild: "PhoneNumber").queryEqual(toValue: phoneNumber).observeSingleEvent(of: .value) { (snapshot) in
            for rest in snapshot.children.allObjects {
                print(rest)
            }
            let isPhoneexists = snapshot.exists()
            if (isPhoneexists) {
                checkComplete(false, "Duplicate number exists")
            } else {
                checkComplete(true, nil)
            }
        }
        
        
        
        
    }
    
}
