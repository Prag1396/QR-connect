//
//  LoginVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 12/30/17.
//  Copyright © 2017 Pragun Sharma. All rights reserved.
//

import UIKit


struct CurrentLength {
    static var currLength: Int = 0
}
class UserSignupVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var phoneNumberLabel: UITextField!
    @IBOutlet weak var phoneNumberAlreaduInUse: UILabel!
    @IBOutlet weak var connectBtn: UIButton!
    
    private var _phoneNumber: String? = nil


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
        
        phoneNumberLabel.delegate = self
        phoneNumberLabel.tag = 1
        phoneNumberLabel.clearsOnBeginEditing = false
        phoneNumberLabel.keyboardAppearance = .dark
        
        
    }
    @IBAction func backbtnpressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkPhoneNumber() {
        AuthService.instance.checkIfPhoneNumberExists(phoneNumber: self.phoneNumberLabel.text!, checkComplete: { (status, errmsg) in
            if status == false {
                
                self.isReadytoPerformSegue = false
                self.phoneNumberAlreaduInUse.isHidden = false
                self.connectBtn.isUserInteractionEnabled = false
                self.connectBtn.alpha = 0.6
                
            } else {
                self.isReadytoPerformSegue = true
                self.phoneNumberAlreaduInUse.isHidden = true
                self.connectBtn.isUserInteractionEnabled = true
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if(textField.tag == 1) {
            self.checkPhoneNumber()
        }
        textField.resignFirstResponder()
        return false
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(phoneNumberLabel.text?.isEmpty == false) {
            self.connectBtn.alpha = 1.0
        }

    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.connectBtn.alpha = 0.6
    }
    
    
    @IBAction func connectBtnPressed(_ sender: Any) {
        captureText()
        if ((phoneNumberLabel.text?.isEmpty)!) {
            //Present Alert
            let alert = UIAlertController(title: "Warning", message: "Please enter your contact number", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }  else if (isReadytoPerformSegue == false) {
            let alert = UIAlertController(title: "Warning", message: "Please enter a valid contact number", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        else {
            //Perform segue to verification
            performSegue(withIdentifier: "connectPressed", sender: (Any).self)
        }
   
    }
    
    func captureText() {
        _phoneNumber = phoneNumberLabel.text!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "connectPressed") {
            if let destination = segue.destination as? ConfirmLoginVC {
                if phoneNumberLabel.text != nil {
                    destination.phoneNumber = _phoneNumber!
                }
            }
            
        }
    }

}
