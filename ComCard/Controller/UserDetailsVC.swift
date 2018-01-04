//
//  UserDetailsVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 12/31/17.
//  Copyright © 2017 Pragun Sharma. All rights reserved.
//

import UIKit

class UserDetailsVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var FullNameTextField: UITextField!
    @IBOutlet weak var CreditCardTextField: UITextField!
    @IBOutlet weak var PhoneNumberTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }
    
    func setupTextFields() {
        FullNameTextField.delegate = self
        CreditCardTextField.delegate = self
        PhoneNumberTextField.delegate = self
        FullNameTextField.allowsEditingTextAttributes = false
        CreditCardTextField.allowsEditingTextAttributes = false
        PhoneNumberTextField.allowsEditingTextAttributes = false
    }
    

    @IBAction func homebtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "homebtnpressed", sender: Any.self)
    }


}
