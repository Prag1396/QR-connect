//
//  LoginVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 12/30/17.
//  Copyright © 2017 Pragun Sharma. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    @IBOutlet weak var phoneNumberLabel: UITextField!
    @IBOutlet weak var cardNumberLabel: UITextField!
    @IBOutlet weak var passCodeLabel: UITextField!
    
    private var _phoneNumber: String? = nil
    private var _firstname: String? = nil
    private var _lastname: String? = nil
    private var _cardNumber: String? = nil
    private var _passcode: String? = nil
    
    var next_responder: UIResponder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        background.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        setupOutlets()
        
    }
    
    @objc func backgroundTapped() {
        view.endEditing(true)
    }
    
    func setupOutlets() {
        firstNameLabel.delegate = self
        firstNameLabel.tag = 1
        lastNameLabel.delegate = self
        lastNameLabel.tag = 2
        phoneNumberLabel.delegate = self
        phoneNumberLabel.tag = 3
        cardNumberLabel.delegate = self
        cardNumberLabel.tag = 4
        passCodeLabel.delegate = self
        passCodeLabel.tag = 5
        firstNameLabel.keyboardAppearance = .dark
        lastNameLabel.keyboardAppearance = .dark
        phoneNumberLabel.keyboardAppearance = .dark
        cardNumberLabel.keyboardAppearance = .dark
        passCodeLabel.keyboardAppearance = .dark
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag: Int = textField.tag + 1
        self.jumpToNextField(textfield: textField, withTag: nextTag)
        return false
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
