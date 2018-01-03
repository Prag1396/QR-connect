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

class ConfirmLoginVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var phoneConfirmText: UITextField!
    @IBOutlet weak var code: UITextField!
    
    private var _firstName: String? = nil
    private var _lastName: String? = nil
    private var _phoneNumber: String? = nil
    private var _cardNumber: String? = nil
    private var _passcode: String? = nil
    
    var firstName: String {
        get {
            return _firstName!
        }
        set {
            self._firstName = newValue
        }
    }
    
    var lastName: String {
        get {
            return _lastName!
        }
        set {
            self._lastName = newValue
        }
    }
    
    var phoneNumber: String {
        get {
            return _phoneNumber!
        }
        set {
            self._phoneNumber = newValue
        }
    }
    
    var cardNumber: String {
        get {
            return _cardNumber!
        }
        set {
            self._cardNumber = newValue
        }
    }
    
    var passcode: String {
        get {
            return _passcode!
        }
        set {
            self._passcode = newValue
        }
    }
    
    @IBAction func sendCodePressed(_ sender: Any) {
        if phoneConfirmText.text != nil {
        AuthService.instance.sendCode(withPhoneNumber: phoneNumber) { (status, error) in
            if error != nil && status == false {
                //Present Alert
                let alert = UIAlertController(title: "Warning", message: "Phone number not recognized. Enter with country code.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                print(error.debugDescription)
                self.present(alert, animated: true, completion: nil)
            }
        }
        }
        
        
    }
    
    
    @IBAction func loginPressed(_ sender: Any) {
        if code.text != nil {
        AuthService.instance.auth(code: code) { (status, error) in
            if error != nil && status == false {
                let alert = UIAlertController(title: "Warning", message: "Invalid Code", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                print(error.debugDescription)
                self.present(alert, animated: true, completion: nil)
            }   else if error == nil && status == true {
                
                    //Call DB_CreateUser to create an user
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "userDetailsVC") as? UserDetailsVC
                    self.present(nextViewController!, animated:true, completion:nil)
            }
        }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneConfirmText.text = _phoneNumber
        phoneConfirmText.allowsEditingTextAttributes = false
        phoneConfirmText.delegate = self
        phoneConfirmText.clearsOnBeginEditing = false
        code.delegate = self
        code.clearsOnBeginEditing = false
        phoneConfirmText.keyboardAppearance = .dark
        code.keyboardAppearance = .dark
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        background.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func backgroundTapped() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
