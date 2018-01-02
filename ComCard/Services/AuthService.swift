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
    
    func auth(code: UITextField, loginComplete: @escaping(_ status: Bool, _ error: Error?) -> ()) {
        
        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "authVID")!, verificationCode: code.text!)
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                loginComplete(false, error)
            } else {
                print("Phonenumber: \(String(describing: user?.phoneNumber))")
                let userInfo = user?.providerData[0]
                print("ProviderID: \(String(describing: userInfo?.providerID))")
                //Login Successfull
                loginComplete(true, nil)

            }
        }
    }

}
