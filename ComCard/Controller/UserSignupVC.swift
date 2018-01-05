//
//  LoginVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 12/30/17.
//  Copyright © 2017 Pragun Sharma. All rights reserved.
//

import UIKit

class UserSignupVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    @IBOutlet weak var phoneNumberLabel: UITextField!
    @IBOutlet weak var cardNumberLabel: UITextField!
    @IBOutlet weak var passCodeLabel: UITextField!
    @IBOutlet weak var phoneNumberAlreaduInUse: UILabel!
    @IBOutlet weak var AlreadyamemberSigninBtn: UIButton!
    @IBOutlet weak var connectBtn: UIButton!
    
    private var _phoneNumber: String? = nil
    private var _firstname: String? = nil
    private var _lastname: String? = nil
    private var _cardNumber: String? = nil
    private var _passcode: String? = nil
    
    var next_responder: UIResponder!
    var isReadytoPerformSegue: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        background.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        setupOutlets()
        isReadytoPerformSegue = true
        
    }
    
    @objc func backgroundTapped() {
        
        view.endEditing(true)
    }
    
    func setupOutlets() {
        firstNameLabel.delegate = self
        firstNameLabel.tag = 1
        firstNameLabel.clearsOnBeginEditing = false
        lastNameLabel.delegate = self
        lastNameLabel.tag = 2
        lastNameLabel.clearsOnBeginEditing = false
        phoneNumberLabel.delegate = self
        phoneNumberLabel.tag = 3
        phoneNumberLabel.clearsOnBeginEditing = false
        cardNumberLabel.delegate = self
        cardNumberLabel.tag = 4
        cardNumberLabel.clearsOnBeginEditing = false
        passCodeLabel.delegate = self
        passCodeLabel.tag = 5
        firstNameLabel.keyboardAppearance = .dark
        lastNameLabel.keyboardAppearance = .dark
        phoneNumberLabel.keyboardAppearance = .dark
        cardNumberLabel.keyboardAppearance = .dark
        passCodeLabel.keyboardAppearance = .dark
    }
    
    func checkPhoneNumber() {
        AuthService.instance.checkIfPhoneNumberExists(phoneNumber: self.phoneNumberLabel.text!, checkComplete: { (status, errmsg) in
            if status == false {
                
                self.isReadytoPerformSegue = false
                self.phoneNumberAlreaduInUse.isHidden = false
                self.connectBtn.isUserInteractionEnabled = false
                self.connectBtn.backgroundColor = UIColor(red: 161/255, green: 172/255, blue: 174/255, alpha: 1.0)

                
            } else {
                self.isReadytoPerformSegue = true
                self.phoneNumberAlreaduInUse.isHidden = true
                self.connectBtn.isUserInteractionEnabled = true
                if(self.firstNameLabel.text?.isEmpty == false && self.lastNameLabel.text?.isEmpty == false && self.phoneNumberLabel.text?.isEmpty == false && self.cardNumberLabel.text?.isEmpty == false && self.passCodeLabel.text?.isEmpty == false) {
                    self.connectBtn.backgroundColor = UIColor(red: 77/255, green: 217/255, blue: 187/255, alpha: 1.0)
                }

            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag: Int = textField.tag + 1
        if(textField.tag == 3) {
            
            self.checkPhoneNumber()
        
        }
        else if(textField.tag == 5) {
            if(self.isReadytoPerformSegue == true) {
                self.connectBtn.backgroundColor = UIColor(red: 77/255, green: 217/255, blue: 187/255, alpha: 1.0)
            }
        }
        self.jumpToNextField(textfield: textField, withTag: nextTag)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(self.isReadytoPerformSegue == true && firstNameLabel.text?.isEmpty == false && lastNameLabel.text?.isEmpty == false && phoneNumberLabel.text?.isEmpty == false && cardNumberLabel.text?.isEmpty == false && passCodeLabel.text?.isEmpty == false) {
            self.connectBtn.backgroundColor = UIColor(red: 77/255, green: 217/255, blue: 187/255, alpha: 1.0)
        }

    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.connectBtn.backgroundColor = UIColor(red: 161/255, green: 172/255, blue: 174/255, alpha: 1.0)
    }
    

    
    func jumpToNextField(textfield: UITextField, withTag tag: Int) {
        
        next_responder = self.view.viewWithTag(tag)
        
        if (tag <= 5) {
            next_responder.becomeFirstResponder()
        } else {
            textfield.resignFirstResponder()
        }
        
    }
    
    @IBAction func backbtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func connectBtnPressed(_ sender: Any) {
        captureText()
        if ((firstNameLabel.text?.isEmpty)! || (lastNameLabel.text?.isEmpty)! || (phoneNumberLabel.text?.isEmpty)! || (cardNumberLabel.text?.isEmpty)! || (passCodeLabel.text?.isEmpty)!) {
            //Present Alert
            let alert = UIAlertController(title: "Warning", message: "Please fill all the text fields", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }  else if (isReadytoPerformSegue == false) {
            let alert = UIAlertController(title: "Warning", message: "Please fill all the text fields", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        else {
        performSegue(withIdentifier: "connectPressed", sender: (Any).self)
            
        }
      
        
    }
    
    func captureText() {
        _firstname = firstNameLabel.text!
        _lastname = lastNameLabel.text!
        _phoneNumber = phoneNumberLabel.text!
        _cardNumber = cardNumberLabel.text!
        _passcode = passCodeLabel.text!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "connectPressed") {
            if let destination = segue.destination as? ConfirmLoginVC {
                if phoneNumberLabel.text != nil {
                    destination.phoneNumber = _phoneNumber!
                }
                if firstNameLabel.text != nil {
                    destination.firstName = _firstname!
                }
                if lastNameLabel.text != nil {
                    destination.lastName = _lastname!
                }
                if cardNumberLabel.text != nil {
                    destination.cardNumber = _cardNumber!
                }
                if passCodeLabel.text != nil {
                    destination.passcode = _passcode!
                }
            }
            
        }
    }

}
