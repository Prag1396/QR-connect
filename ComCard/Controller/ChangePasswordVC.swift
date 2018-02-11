//
//  ChangePasswordVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/10/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ChangePasswordVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var currentPwdLabel: UITextField!
    @IBOutlet weak var newPasswordLabel: UITextField!
    
    var next_responder: UIResponder!
    
    private var _emailDownloaded: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadUserInformation()
        self.setUpOutlets()
        // Do any additional setup after loading the view.
    }
    
    func setUpOutlets() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backGroundTapped))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        currentPwdLabel.delegate = self
        currentPwdLabel.tag = 1
        currentPwdLabel.keyboardAppearance = .dark
        
        newPasswordLabel.delegate = self
        newPasswordLabel.tag = 2
        newPasswordLabel.keyboardAppearance = .dark
        
        
    }
    
    func downloadUserInformation() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userRef = DataService.instance.REF_BASE
        userRef.child("pvtdata").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                self._emailDownloaded = dict["Email"] as? String
            } else {
                //Show Alert
                print("Could not find user")
            }
        }
    }
    
    @objc func backGroundTapped() {
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
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        if (currentPwdLabel.text?.isEmpty == false && currentPwdLabel.text != nil && newPasswordLabel.text?.isEmpty == false && newPasswordLabel.text != nil) {
            
            if let currentemail = self._emailDownloaded {
                AuthService.instance.changePassword(withEmail: currentemail, currentPassword: currentPwdLabel.text!, andNewPassword: newPasswordLabel.text!, onReauthenticationComplete: { (status, error) in
                    if error != nil {
                        let alert = UIAlertController(title: "Warning", message: error?.localizedDescription ?? String(), preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)

                    } else {
                        //show alert of password changed successfully
                        let alert = UIAlertController(title: "Congratulations!", message: "Password has been changed successfully", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                            self.signoutUser()
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
            
        } else {
            //Show alert
            let alert = UIAlertController(title: "Warning", message: "All fields must be entered", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func signoutUser() {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let controllerToPresent = storyBoard.instantiateViewController(withIdentifier: "userSignin") as? UserSigninVC
            self.present(controllerToPresent!, animated: true, completion: nil)
        } catch let signouterror as NSError {
            print("Error signing out: \(signouterror)")
        }
    }

    @IBAction func backbtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
