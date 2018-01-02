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

class ConfirmLoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var phoneConfirmText: UITextField!
    @IBOutlet weak var code: UITextField!
    
    private var _phoneNumber: String = ""
    
    var phoneNumber: String {
        get {
            return _phoneNumber
        }
        set {
            self._phoneNumber = newValue
        }
    }
    
    @IBAction func sendCodePressed(_ sender: Any) {
        
        AuthService.instance.sendCode(withPhoneNumber: phoneNumber) { (status, error) in
            if error != nil && status == false {
                //Present Alert
                let alert = UIAlertController(title: "Warning", message: "Phone number not recognized. Enter with country code.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                print(error.debugDescription)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
    
    @IBAction func loginPressed(_ sender: Any) {
        
        AuthService.instance.auth(code: code) { (status, error) in
            if error != nil && status == false {
                let alert = UIAlertController(title: "Warning", message: "Invalid Code", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                print(error.debugDescription)
                self.present(alert, animated: true, completion: nil)
            }   else if error == nil && status == true {
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "userDetailsVC") as? UserDetailsVC
                    self.present(nextViewController!, animated:true, completion:nil)
            }
        }

        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneConfirmText.text = _phoneNumber
        phoneConfirmText.allowsEditingTextAttributes = false
        phoneConfirmText.delegate = self
        code.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
