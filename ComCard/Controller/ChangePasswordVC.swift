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
import PCLBlurEffectAlert

class ChangePasswordVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var currentPwdLabel: UITextField!
    @IBOutlet weak var newPasswordLabel: UITextField!
    @IBOutlet weak var confirmbtn: UIButton!
    
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
        confirmbtn.isMultipleTouchEnabled = false
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
                        let alert = PCLBlurEffectAlertController(title: "Warning", message: error?.localizedDescription, effect: UIBlurEffect(style: .light), style: .alert)
                        alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                            UIView.animate(withDuration: 0.5, animations: {
                                self.view.alpha = 1.0
                                
                            })
                        }))
                        alert.configureAlert(alert: alert)
                        self.view.alpha = 0.7
                        alert.show()

                    } else {
                        //show alert of password changed successfully
                        let alert = PCLBlurEffectAlertController(title: "Congratulations", message: "Password has been successfully changed", effect: UIBlurEffect(style: .light), style: .alert)
                        alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                            UIView.animate(withDuration: 0.5, animations: {
                                self.view.alpha = 1.0
                                self.signoutUser()
                            })
                        }))
                        alert.configureAlert(alert: alert)
                        alert.configure(titleColor: UIColor(red: 77/255, green: 225/255, blue: 158/255, alpha: 1.0))
                        self.view.alpha = 0.7
                        alert.show()
                    }
                })
            }
            
        } else {
            //Show alert
            let alert = PCLBlurEffectAlertController(title: "Warning", message: "All fields must be entered", effect: UIBlurEffect(style: .light), style: .alert)
            alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.alpha = 1.0
                })
            }))
            alert.configureAlert(alert: alert)
            self.view.alpha = 0.7
            alert.show()
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
