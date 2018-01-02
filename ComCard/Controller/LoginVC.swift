//
//  LoginVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 12/30/17.
//  Copyright © 2017 Pragun Sharma. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    @IBOutlet weak var phoneNumberLabel: UITextField!
    @IBOutlet weak var cardNumberLabel: UITextField!
    @IBOutlet weak var passCodeLabel: UITextField!
    
    private var _phoneNumber: String = ""
    let numberToolbar: UIToolbar = UIToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberLabel.delegate = self
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func backbtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func connectBtnPressed(_ sender: Any) {
        _phoneNumber = phoneNumberLabel.text!
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "connectPressed") {
            if let destination = segue.destination as? ConfirmLoginVC {
                if phoneNumberLabel.text != nil {
                    destination.phoneNumber = _phoneNumber
                }
            }
            
        }
    }

}
