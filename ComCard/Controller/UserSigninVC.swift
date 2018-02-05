//
//  UserSigninVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/2/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage



class UserSigninVC: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    var next_Responder: UIResponder!

    
    let userID = Auth.auth().currentUser?.uid
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.delegate = self
        userNameTextField.tag = 1
        userNameTextField.clearsOnBeginEditing = false
        passwordTextField.delegate = self
        passwordTextField.tag = 2
        userNameTextField.keyboardAppearance = .dark
        passwordTextField.keyboardAppearance = .dark
        passwordTextField.clearsOnBeginEditing = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        background.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag: Int = textField.tag + 1
        self.jumpToNextField(textfield: textField, withTag: nextTag)
        return false
    }

    func jumpToNextField(textfield: UITextField, withTag tag: Int) {
        
        next_Responder = self.view.viewWithTag(tag)
        if(tag <= 2) {
            next_Responder.becomeFirstResponder()
        } else {
            textfield.resignFirstResponder()
        }

        
    }
    
    @objc func backgroundTapped() {
        view.endEditing(true)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signInBtnTapped(_ sender: Any) {
        
        if userNameTextField.text != nil && passwordTextField.text != nil {
            
            AuthService.instance.loginUser(withEmail: userNameTextField.text!, andPassword: passwordTextField.text!, loginComplete: { (success, loginError) in
                if success {
                    //perform segue
                    self.performSegue(withIdentifier: "signinsuccessfull", sender: Any.self)
                } else {
                    if let loginerror = loginError {
                        AuthService.instance.handleErrorCode(error: loginerror as NSError, onCompleteErrorHandler: { (errmsg, nil) in
                            let alert = UIAlertController(title: "Warning", message: errmsg, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        })
                    }
                }
            })
            
        }
 
    }
    
}
