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
import PCLBlurEffectAlert

class ConfirmLoginVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var verifybtn: buttonStyle!
    @IBOutlet weak var resendCode: buttonStyle!
    
    private var _phoneNumber: String? = nil
    private var _finalCode: String? = nil
    
    var next_responder: UIResponder!
    
    @IBOutlet weak var cd1: UITextField!
    @IBOutlet weak var cd6: UITextField!
    @IBOutlet weak var cd5: UITextField!
    @IBOutlet weak var cd4: UITextField!
    @IBOutlet weak var cd3: UITextField!
    @IBOutlet weak var cd2: UITextField!
    
    var phoneNumber: String? {
        get {
            return _phoneNumber!
        }
        set {
            self._phoneNumber = newValue
        }
    }
    
    func setupOutlets() {
        cd1.delegate = self
        cd1.keyboardAppearance = .dark
        cd1.tag = 1
        cd1.addTarget(self, action: #selector(self.textfieldDidChange(textfield: )), for: UIControlEvents.editingChanged)
        cd2.delegate = self
        cd2.keyboardAppearance = .dark
        cd2.tag = 2
        cd2.addTarget(self, action: #selector(self.textfieldDidChange(textfield: )), for: UIControlEvents.editingChanged)
        cd3.delegate = self
        cd3.keyboardAppearance = .dark
        cd3.tag = 3
        cd3.addTarget(self, action: #selector(self.textfieldDidChange(textfield: )), for: UIControlEvents.editingChanged)
        cd4.delegate = self
        cd4.keyboardAppearance = .dark
        cd4.tag = 4
        cd4.addTarget(self, action: #selector(self.textfieldDidChange(textfield: )), for: UIControlEvents.editingChanged)
        cd5.delegate = self
        cd5.keyboardAppearance = .dark
        cd5.tag = 5
        cd5.addTarget(self, action: #selector(self.textfieldDidChange(textfield: )), for: UIControlEvents.editingChanged)
        cd6.delegate = self
        cd6.keyboardAppearance = .dark
        cd6.tag = 6
        cd6.addTarget(self, action: #selector(self.textfieldDidChange(textfield: )), for: UIControlEvents.editingChanged)
    }
    
    @objc func resendCodePressed() {
        
        self.resendCode.setTitle("SENT. RESEND CODE?", for: .normal)
        self.sendcode()
    }
    
    
    //Send code to device
    @objc func sendcode() {
      
        guard let phonenumber = self.phoneNumber else {
            return
        }
        AuthService.instance.sendCode(withPhoneNumber: phonenumber) { (status, error) in

            if error != nil && status == false {
                //Present Alert
                AuthService.instance.handleErrorCode(error: (error as NSError?)!, onCompleteErrorHandler: { (errmsg, nil) in
                    
                    let alert = PCLBlurEffectAlertController(title: "Warning", message: "\(errmsg)", effect: UIBlurEffect(style: .light), style: .alert)
                    alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                        UIView.animate(withDuration: 0.5, animations: {
                            self.view.alpha = 1.0
                        })
                    }))
                    alert.configureAlert(alert: alert)
                    self.view.alpha = 0.7
                    alert.show()
                    
                })
            } else if error == nil && status == false {

                let alert = PCLBlurEffectAlertController(title: "Warning", message: "Unable to send code", effect: UIBlurEffect(style: .light), style: .alert)
                alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (actions) in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.view.alpha = 1.0
                    })
                    self.performSegue(withIdentifier: "backbtnpressedinconfirmvc", sender: Any.self)
                }))
                alert.configureAlert(alert: alert)
                self.view.alpha = 0.7
                alert.show()
                

            }

        }
        
    }
    
    @objc func textfieldDidChange(textfield: UITextField) {
        let nextTag: Int = textfield.tag + 1
        self.jumpToNextField(textfield: textfield, withTag: nextTag)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = "";
    }
    
    func jumpToNextField(textfield: UITextField, withTag tag: Int) {
        
        next_responder = self.view.viewWithTag(tag)
        
        if (tag <= 6) {
            next_responder.becomeFirstResponder()
        } else {
            textfield.resignFirstResponder()
        }
        
    }
    
    @IBAction func backbtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func captureInputAndCombine() {
        guard let input1 = cd1.text, let input2 = cd2.text, let input3 = cd3.text,let input4 = cd4.text, let input5 = cd5.text, let input6 = cd6.text else {
            return
        }
        self._finalCode = input1 + input2 + input3 + input4 + input5 + input6
        //print(self._finalCode ?? String())
        
    }
    
    //Login Before verification
    @IBAction func loginPressed(_ sender: Any) {
        self.captureInputAndCombine()
        guard let finalCode = self._finalCode else {
            return
        }
        AuthService.instance.auth(code: finalCode) { (status, error) in
            if error != nil && status == false {
                AuthService.instance.handleErrorCode(error: (error as NSError?)!, onCompleteErrorHandler: { (errmsg, nil) in
                    
                    //ADD CUSTOM ALERT
                    let alert = PCLBlurEffectAlertController(title: "Warning", message: errmsg, effect: UIBlurEffect(style: .light), style: .alert)
                    alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                        UIView.animate(withDuration: 0.5, animations: {
                            self.view.alpha = 1.0
                        })
                    }))
                    alert.configureAlert(alert: alert)
                    self.view.alpha = 0.7
                    alert.show()
                    
                })


            }   else if error == nil && status == true {
                
                //Perform segue to emailcapture
                
                self.performSegue(withIdentifier: "phoneauthsuccessfull", sender: Any.self)
            }
                

        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verifybtn.isMultipleTouchEnabled = false
        self.setupOutlets();
        self.sendcode();
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        background.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        resendCode.addTarget(self, action: #selector(self.resendCodePressed), for: UIControlEvents.touchUpInside)

    }
    
    @objc func backgroundTapped() {
        self.view.endEditing(true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "phoneauthsuccessfull") {
            if let destination = segue.destination as? EmailCaptureVC {
                if let mynumber = self.phoneNumber {
                    destination.phoneNumber = mynumber
                }
            }
            
        }
    }
    
}
