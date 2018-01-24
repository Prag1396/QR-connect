//
//  NameCaptureVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/18/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class NameCaptureVC: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {

    @IBOutlet weak var donebtn: UIButton!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var background: UIImageView!
    
    var next_responder: UIResponder!
    var isReadytoPerformSegue: Bool!
    
    private var _imageURL: String? = nil
    private var _phonenumber: String? = nil
    private var _email: String? = nil
    private var _password: String? = nil
    private var _firstName: String? = nil
    private var _lastName: String? = nil
    private var _currentUserID: String = (Auth.auth().currentUser?.uid)!
    
    var phoneNumber: String {
        get {
            return _phonenumber!
        }
        set {
            self._phonenumber = newValue
        }
    }
    
    var email: String {
        get {
            return _email!
        } set {
            self._email = newValue
        }
    }
    
    var password: String {
        get {
            return _password!
        }
        set {
            self._password = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        background.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        firstName.delegate = self
        lastName.delegate = self
        firstName.keyboardAppearance = .dark
        lastName.keyboardAppearance = .dark
        firstName.tag = 1
        lastName.tag = 2
        
        // Do any additional setup after loading the view.
    }

    
    @objc func backgroundTapped() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag: Int = textField.tag + 1

        self.jumpToNextField(textfield: textField, withTag: nextTag)
        return false
    }
    
    func jumpToNextField(textfield: UITextField, withTag tag: Int) {
        
        next_responder = self.view.viewWithTag(tag)
        
        if (tag <= 2) {
            next_responder.becomeFirstResponder()
        } else {
            textfield.resignFirstResponder()
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.donebtn.alpha = 0.6
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(self.isReadytoPerformSegue == true && firstName.text?.isEmpty == false && lastName.text?.isEmpty == false) {
            self.donebtn.alpha = 1.0
        }
        
    }
    
    func captureText() {
        _firstName = firstName.text!
        _lastName = lastName.text!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func donebtnpressed(_ sender: Any) {
        captureText()
        if ((firstName.text?.isEmpty)! || (lastName.text?.isEmpty)!) {
            //Present Alert
            let alert = UIAlertController(title: "Warning", message: "Please enter your full name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            //Create DB User
            AuthService.instance.registerUser(withEmail: self.email, andPassword: self.password, firstName: self._firstName!, lastname: self._lastName!, phonenumber: self.phoneNumber,userCreationComplete: { (userID, success, registrationError)  in
                if success {
                    AuthService.instance.loginUser(withEmail: self.email, andPassword: self.password, loginComplete: { (success, nil) in
                        
                        print("Successfully registered user")
                        self.performSegue(withIdentifier: "loaduserdetails", sender: Any.self)
                    })
                } else {
                    print(String(describing: registrationError?.localizedDescription))
                }
            })
            
        }
    }

}
