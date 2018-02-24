//
//  EmailCaptureVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/18/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import PCLBlurEffectAlert

class EmailCaptureVC: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var continuebtn: UIButton!
    @IBOutlet weak var background: UIImageView!
    
    private var _email: String? = nil
    private var _phonenumber: String? = nil
    var isReadytoPerformSegue: Bool!

    
    var phoneNumber: String {
        get {
            return _phonenumber!
        }
        set {
            self._phonenumber = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        background.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        isReadytoPerformSegue = true
        setupOutlets()
        // Do any additional setup after loading the view.
    }
    
    func setupOutlets() {
        emailTextField.delegate = self
        emailTextField.clearsOnBeginEditing = true
        emailTextField.keyboardAppearance = .dark
        emailTextField.tag = 1
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField.tag == 1) {
            self.checkifEmailExists()
        }
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(emailTextField.text?.isEmpty == false) {
            self.continuebtn.alpha = 1.0
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.continuebtn.alpha = 0.6
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func continuebrnpressed(_ sender: Any) {
        captureText()
        if ((emailTextField.text?.isEmpty)!) {
            //ADD CUSTOM ALERT
            
            let alert = PCLBlurEffectAlertController(title: "Warning", message: "Please enter your email address", effect: UIBlurEffect(style: .light), style: .alert)
            alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                self.view.alpha = 1.0
            }))
            alert.configureAlert(alert: alert)
            self.view.alpha = 0.7
            alert.show()
            
        } else if (isReadytoPerformSegue == false) {
            let alert = PCLBlurEffectAlertController(title: "Warning", message: "Email aready in use", effect: UIBlurEffect(style: .light), style: .alert)
            alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                self.view.alpha = 1.0
            }))
            alert.configureAlert(alert: alert)
            self.view.alpha = 0.7
            alert.show()
        } else {
            //Perform segue to password
             self.performSegue(withIdentifier: "emailcaptured", sender: Any.self)
        }
    }
    
    func checkifEmailExists() {
        //If email does not exists
       // isReadytoPerformSegue = true then allow btn interaction
    }
    
    func captureText() {
        _email = emailTextField.text?.trimmingCharacters(in: .whitespaces)
        
    }
    
    @objc func backgroundTapped() {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "emailcaptured") {
            if let destination = segue.destination as? PasswordCaptureVC {
                if emailTextField.text != nil {
                    destination.email = _email!
                    destination.phoneNumber = _phonenumber!
                }
                
            }
            
        }
    }
    
    
}
