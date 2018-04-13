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
import RNCryptor
import FirebaseMessaging
import PCLBlurEffectAlert

class AuthService: UIViewController {
    static let instance = AuthService()
    let defaults = UserDefaults.standard
    private var phoneAuthCredential: PhoneAuthCredential?
    private var _encryptKey = "JJ13962896QRConnectDec12"
    
    func sendCode(withPhoneNumber phoneNumber: String, messageSentComplete: @escaping(_ status: Bool, _ error: Error?) -> ()) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if error != nil {
                messageSentComplete(false, error)
            } else {
                        self.defaults.set(verificationID, forKey: "authVID")
                        self.defaults.synchronize()
                        messageSentComplete(true, nil)

                    }
            
                
            }
    }
    
    func auth(code: UITextField, authorizationComplete: @escaping(_ status: Bool, _ error: Error?) -> ()) {
        guard let verificationID = defaults.string(forKey: "authVID") else {
            //present error
               let alert = PCLBlurEffectAlertController(title: "Warning", message: "Unable to authenticate device", effect: UIBlurEffect(style: .light), style: .alert)
            alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.alpha = 1.0
                })
            }))
            alert.configureAlert(alert: alert)
            self.view.alpha = 0.7
            alert.show()
            
            return
        }
        phoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code.text!.trimmingCharacters(in: .whitespaces))
        if let pac = phoneAuthCredential {
            Auth.auth().signIn(with: pac) { (user, error) in
                if error != nil {
                    authorizationComplete(false, error)
                } else {
                    //Authorization successfull
                    authorizationComplete(true, nil)
                }
            }
        }

    }
    
        
    func registerUser(withEmail email: String, andPassword password: String, firstName: String, lastname: String, phonenumber: String, userCreationComplete: @escaping (_ uid: String?, _ status: Bool, _ error: Error?) -> ()) {
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let credentials = EmailAuthProvider.credential(withEmail: email, password: password)
        user.link(with: credentials) { (user, error) in
            if error != nil {
                print(error.debugDescription)
                userCreationComplete(nil, false, error)
                
            } else {
                print("Linked Successfully")
                let data = ("\(email) \(firstName) \((user?.uid)!)").data(using: String.Encoding.utf8, allowLossyConversion: false)
                //encrypt data
                let encryptedData = RNCryptor.encrypt(data: data!, withPassword: self._encryptKey)
                let compressed =  encryptedData.base64EncodedData()
                self.uploadQRCode(uid: (user?.uid)!, data: compressed) { (imageURL, status, error) in
                    if error != nil {
                        print("error uploading image")
                    } else {
                        
                        guard let fcmtoken = Messaging.messaging().fcmToken else {
                            return
                        }
                        
                        let userData: Dictionary<String, String> = ["FirstName" :firstName, "lastName": lastname, "imageURL": imageURL!, "token": fcmtoken, "unreadMessagesCounter": String(0)]
                        let pvtData: Dictionary<String, String> = ["PhoneNumber": phonenumber, "Email": email]
                        DataService.instance.createDBUserProfile(uid: (user?.uid)!, userData: userData)
                        DataService.instance.createPrivateData(uid: (user?.uid)!, userData: pvtData)
                        
                        userCreationComplete((user?.uid)!, true, nil)
                        
                    }
                }
                
            }
        }
    }
    
    func uploadQRCode(uid: String, data: Data, onUploadingImageComplete: @escaping (_ imageURL: String?,_ status: Bool, _ error: Error?)->()) {
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        
        let imageToUpload = convertToUIImage(c_image: (filter?.outputImage)!)
        StorageService.instance.uploadImage(withuserID: uid, image: imageToUpload) { (status, error, url) in
            if (error != nil) {
                
                let alert = PCLBlurEffectAlertController(title: "Warning", message: error?.localizedDescription, effect: UIBlurEffect(style: .light), style: .alert)
                alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.view.alpha = 1.0
                    })
                }))
                onUploadingImageComplete(nil,false, error)
                alert.configureAlert(alert: alert)
                self.view.alpha = 0.7
                alert.show()
                
                
                
            } else {
                print("Uploaded Successfully")
                onUploadingImageComplete("\(url!)", true, nil)
                
            }
            
        }
    }
    
    func convertToUIImage(c_image: CIImage) -> UIImage {
        let context:CIContext = CIContext.init(options: nil)
        let transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        let img = c_image.transformed(by: transform)
        let cgImage:CGImage = context.createCGImage(img, from: c_image.extent)!
        
        let image: UIImage = UIImage.init(cgImage: cgImage)
        
        //Change size
        let scaledImage = image.scaleUIImageToSize(image: image, size: CGSize(width: 120, height: 120))
        return scaledImage
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
    
    
    func changePassword(withEmail email: String, currentPassword: String, andNewPassword newpassword: String, onReauthenticationComplete: @escaping (_ status: Bool, _ error: Error?)->()) {
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (error) in
            if error != nil {
                onReauthenticationComplete(false, error)
                return
            }
            //Re-Authentication successfull
            Auth.auth().currentUser?.updatePassword(to: newpassword, completion: { (error) in
                if error != nil {
                    print(error.debugDescription)
                    onReauthenticationComplete(false, error)
                    return
                }
                //New Password set successfully
                onReauthenticationComplete(true, nil)
            })
        })
    }
    
    func forgotPassword(withEmail email: String, onComplete: @escaping (_ status: Bool, _ error: Error?)->()) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
            if error != nil {
                onComplete(false, error)
            } else {
                onComplete(true, nil)
            }
        })
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
            case .userNotFound: do {
                onCompleteErrorHandler("User not found. Please sign up", nil)
                }
            case .sessionExpired: do {
                onCompleteErrorHandler("Session Expired", nil)
                }
            case .invalidEmail: do {
                onCompleteErrorHandler("Invalid Email", nil)
                }

            default:
                onCompleteErrorHandler("Internal Error. Please try again.", nil)
            
            }
        }
    }
}
