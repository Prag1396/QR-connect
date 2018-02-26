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
import PCLBlurEffectAlert
import TKSubmitTransition


class UserSigninVC: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var signinBtn: TKTransitionSubmitButton?
    
    var next_Responder: UIResponder!
    private var _contactbtnwassender: Bool!
    private var _emailDownloaded: String? = nil
    
    let userID = Auth.auth().currentUser?.uid
    
    var contactbuttonwassender: Bool? {
        get {
            return _contactbtnwassender!
        }
        set {
            _contactbtnwassender = newValue
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TKFadeInAnimator(transitionDuration: 0.5, startingAlpha: 0.5)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.downloadUsername()
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
    
    func downloadUsername() {
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
    
    
    @IBAction func forgotPasswordBtnPressed(_ sender: Any) {
        if let email = self._emailDownloaded {
            AuthService.instance.forgotPassword(withEmail: email, onComplete: { (status, error) in
                if error != nil {
                    
                    let alert = PCLBlurEffectAlertController(title: "Warning", message: error?.localizedDescription, effect: UIBlurEffect(style: .light), style: .alert)
                    alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.view.alpha = 1.0
                    }))
                    alert.configureAlert(alert: alert)
                    self.view.alpha = 0.7
                    alert.show()
                    
                } else {
                    let alert = PCLBlurEffectAlertController(title: "Warning", message: "An email has been sent to you with instructions on how to reset your password", effect: UIBlurEffect(style: .light), style: .alert)
                    alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.view.alpha = 1.0
                    }))
                    alert.configureAlert(alert: alert)
                    self.view.alpha = 0.7
                    alert.show()
                }
            })
        } else {
            //Show alert
            let alert = PCLBlurEffectAlertController(title: "Warning", message: "Could not find user", effect: UIBlurEffect(style: .light), style: .alert)
            alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                self.view.alpha = 1.0
            }))
            alert.configureAlert(alert: alert)
            self.view.alpha = 0.7
            alert.show()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signInBtnTapped(_ sender: Any) {
        
        if userNameTextField.text != nil && passwordTextField.text != nil && userNameTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false {
            
            AuthService.instance.loginUser(withEmail: userNameTextField.text!, andPassword: passwordTextField.text!, loginComplete: { (success, loginError) in
                if success {
                    self.signinBtn?.startLoadingAnimation()
                    
                    if self.contactbuttonwassender == false {
                        self.signinBtn?.startFinishAnimation(0.3, completion: {
                            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                            let controllerToPresent = storyBoard.instantiateViewController(withIdentifier: "tabbarvc") as? UITabBarController
                            if let vc = controllerToPresent {
                                self.present(vc, animated: true, completion: nil)
                            }
                        })
                        
                    } else if self.contactbuttonwassender == true {
                        self.signinBtn?.startFinishAnimation(0, completion: {
                            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                            let controllerToPresent = storyBoard.instantiateViewController(withIdentifier: "tabbarvc") as? UITabBarController
                            if let vc = controllerToPresent {
                                vc.selectedIndex = 1
                                self.present(vc, animated: true, completion: nil)
                            }
                        })
                    }
                    
                } else {
                    if let loginerror = loginError {
                        AuthService.instance.handleErrorCode(error: loginerror as NSError, onCompleteErrorHandler: { (errmsg, nil) in
                            //ADD CUSTOM ALERTVIEW
                            
                            let alert = PCLBlurEffectAlertController(title: "Warning", message: errmsg, effect: UIBlurEffect(style: .light), style: .alert)
                            alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                                self.view.alpha = 1.0
                            }))
                            alert.configureAlert(alert: alert)
                            self.view.alpha = 0.7
                            alert.show()

                        })
                    }
                }
            })
            
        } else {
            let alert = PCLBlurEffectAlertController(title: "Warning", message: "All fields must be entered", effect: UIBlurEffect(style: .light), style: .alert)
            alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                self.view.alpha = 1.0
            }))
            alert.configureAlert(alert: alert)
            self.view.alpha = 0.7
            alert.show()
        }
 
    }
    
}
