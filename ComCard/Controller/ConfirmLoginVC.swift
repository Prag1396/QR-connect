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
    @IBOutlet weak var sendCodeButton: UIButton!
    
    private var _phoneNumber: String? = nil
    
    
    var phoneNumber: String {
        get {
            return _phoneNumber!
        }
        set {
            self._phoneNumber = newValue
        }
    }
    
    
    //Send code to device
    @IBAction func sendCodePressed(_ sender: Any) {
        if phoneConfirmText.text != nil {
        AuthService.instance.sendCode(withPhoneNumber: phoneNumber) { (status, error) in
            if error != nil && status == false {
                //Present Alert
                AuthService.instance.handleErrorCode(error: error as NSError!, onCompleteErrorHandler: { (errmsg, nil) in
                    let alert = UIAlertController(title: "Warning", message: "\(errmsg)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            } else if error == nil && status == false {
                    let alert = UIAlertController(title: "Warning", message: "Unable to send code", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                    self.performSegue(withIdentifier: "backbtnpressedinconfirmvc", sender: Any.self)

                }))
                    self.present(alert, animated: true, completion: nil)

            }
            else if (status == true) {
                print("here")
                self.sendCodeButton.setTitle("SENT. RESEND CODE?", for: .normal)
            }
        }
        }
        
        
    }
    
    @IBAction func backbtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Login Before verification
    @IBAction func loginPressed(_ sender: Any) {
        if code.text != nil {
        AuthService.instance.auth(code: code) { (status, error) in
            if error != nil && status == false {
                AuthService.instance.handleErrorCode(error: error as NSError!, onCompleteErrorHandler: { (errmsg, nil) in
                    let alert = UIAlertController(title: "Warning", message: "\(errmsg)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })


            }   else if error == nil && status == true {
                
                //Perform segue to emailcapture
                
                self.performSegue(withIdentifier: "phoneauthsuccessfull", sender: Any.self)
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
        self.sendCodeButton.setTitle("SEND CODE", for: .normal)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "phoneauthsuccessfull") {
            if let destination = segue.destination as? EmailCaptureVC {
                if phoneConfirmText.text != nil {
                    destination.phoneNumber = phoneConfirmText.text!
                }
            }
            
        }
    }
    
}
