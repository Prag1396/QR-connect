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
import PCLBlurEffectAlert

class NameCaptureVC: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {

    @IBOutlet weak var donebtn: UIButton!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var background: UIImageView!
    
    var next_responder: UIResponder!
    
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
        if(firstName.text?.isEmpty == false && lastName.text?.isEmpty == false) {
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
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBAction func donebtnpressed(_ sender: Any) {
        
        setUpActivityIndicator()
        activityIndicator.startAnimating()
        captureText()
        
        if ((firstName.text?.isEmpty)! || (lastName.text?.isEmpty)!) {
            //Present Alert
            let alert = PCLBlurEffectAlertController(title: "Warning", message: "Please enter your full name", effect: UIBlurEffect(style: .light), style: .alert)
            alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                self.view.alpha = 1.0
            }))
            alert.configureAlert(alert: alert)
            self.view.alpha = 0.7
            alert.show()
            
        } else {
            //Create DB User
            AuthService.instance.registerUser(withEmail: self.email, andPassword: self.password, firstName: self._firstName!, lastname: self._lastName!, phonenumber: self.phoneNumber,userCreationComplete: { (userID, success, registrationError)  in
                if success {
                    AuthService.instance.loginUser(withEmail: self.email, andPassword: self.password, loginComplete: { (success, nil) in
                        
                        print("Successfully registered user")
                        self.activityIndicator.stopAnimating()
                        self.performSegue(withIdentifier: "loaduserdetails", sender: Any.self)
                    })
                } else {
                    print(String(describing: registrationError?.localizedDescription))
                }
            })
            
        }
    }
    
    func setUpActivityIndicator() {
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = self.view.center
        loadingView.backgroundColor = UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width/2, y: loadingView.frame.size.height/2)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        loadingView.addSubview(activityIndicator)
        view.addSubview(loadingView)
        
    }

}
