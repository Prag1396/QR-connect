//
//  ConfirmLoginVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 12/31/17.
//  Copyright © 2017 Pragun Sharma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ConfirmLoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var phoneConfirmText: UITextField!
    @IBOutlet weak var code: UITextField!
    
    private var _phoneNumber: String = ""
    let defaults = UserDefaults.standard
    
    var phoneNumber: String {
        get {
            return _phoneNumber
        }
        set {
            self._phoneNumber = newValue
        }
    }
    
    @IBAction func sendCodePressed(_ sender: Any) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if error != nil {
                let alert = UIAlertController(title: "Warning", message: "Phone Number not Recognized. Enter with country code", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                print(error.debugDescription)
                self.present(alert, animated: true, completion: nil)

            } else {
                self.defaults.set(verificationID, forKey: "authVID")
                
            }
        }
        
    }
    
    
    @IBAction func loginPressed(_ sender: Any) {
        
        
        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "authVID")!, verificationCode: self.code.text!)
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                let alert = UIAlertController(title: "Warning", message: "Invalid Code", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                print(error.debugDescription)
                self.present(alert, animated: true, completion: nil)
            } else {
                print("Phonenumber: \(String(describing: user?.phoneNumber))")
                let userInfo = user?.providerData[0]
                print("ProviderID: \(String(describing: userInfo?.providerID))")
                //Load USER INFO View Controller
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "userDetailsVC") as? UserDetailsVC
                self.present(nextViewController!, animated:true, completion:nil)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneConfirmText.text = _phoneNumber
        phoneConfirmText.allowsEditingTextAttributes = false
        phoneConfirmText.delegate = self
        code.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
