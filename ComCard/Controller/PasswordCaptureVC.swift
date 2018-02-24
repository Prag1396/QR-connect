//
//  PasswordCaptureVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/18/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import PCLBlurEffectAlert

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
            //ADD CUSTOM ALERT
            let alert = PCLBlurEffectAlertController(title: "Warning", message: "Please enter a valid password (minimum 6 digits)", effect: UIBlurEffect(style: .light), style: .alert)
            alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                self.view.alpha = 1.0
            }))
            alert.configureAlert(alert: alert)
            self.view.alpha = 0.7
            alert.show()
            
        } else {
            //Perform segue to password
            self.performSegue(withIdentifier: "passwordcaptured", sender: Any.self)
        }
    }
    
    func captureText() {
        _password = passwordTextField.text!.trimmingCharacters(in: .whitespaces)
        
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
