//
//  UserSigninVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/2/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class UserSigninVC: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    var next_Responder: UIResponder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.delegate = self
        userNameTextField.tag = 1
        userNameTextField.clearsOnBeginEditing = false
        passwordTextField.delegate = self
        passwordTextField.tag = 2
        passwordTextField.clearsOnBeginEditing = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        background.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag: Int = textField.tag + 1
        self.jumpToNextField(textfield: textField, withTag: nextTag)
        return false
    }

    func jumpToNextField(textfield: UITextField, withTag tag: Int) {
        
        next_Responder = self.view.viewWithTag(tag)
        if(tag <= 2) {
            next_Responder.becomeFirstResponder()
        } else {
            textfield.resignFirstResponder()
        }

        
    }
    
    @objc func backgroundTapped() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backbtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func signInBtnTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "signInComplete", sender: Any.self)
    }
    
}
