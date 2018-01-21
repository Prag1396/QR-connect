//
//  PasswordCaptureVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/18/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class PasswordCaptureVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var nextbtn: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var _email: String? = nil
    private var _phonenumber: String? = nil
    private var _password: String? = nil
    
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
        }
        set {
            self._email = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        background.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        setupOutlets()
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.nextbtn.alpha = 0.6
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(passwordTextField.text?.isEmpty == false) {
            self.nextbtn.alpha = 1.0
        }
        
    }
    
    func setupOutlets() {
        passwordTextField.delegate = self
        passwordTextField.clearsOnBeginEditing = true
        passwordTextField.keyboardAppearance = .dark
    }
    
    @objc func backgroundTapped() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextbtnpressed(_ sender: Any) {
        captureText()
        if ((passwordTextField.text?.isEmpty)!) {
            //Present Alert
            let alert = UIAlertController(title: "Warning", message: "Please enter a password for your account", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            //Perform segue to password
            self.performSegue(withIdentifier: "passwordcaptured", sender: Any.self)
        }
    }
    
    func captureText() {
        _password = passwordTextField.text!
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "passwordcaptured") {
            if let destination = segue.destination as? NameCaptureVC {
                if passwordTextField.text != nil {
                    destination.password = _password!
                    destination.email = _email!
                    destination.phoneNumber = _phonenumber!
                    
                }
            }
            
        }
    }
    
    

}
