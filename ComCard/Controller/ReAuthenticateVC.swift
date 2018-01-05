//
//  ReAuthenticateVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/4/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class ReAuthenticateVC: UIViewController, UITextFieldDelegate {

    private var _phonenumber: String? = nil
    
    @IBOutlet weak var phoneNumbertextField: UITextField!
    
    var phoneNumber: String {
        get {
            return _phonenumber!
        } set {
            self._phonenumber = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumbertextField.allowsEditingTextAttributes = false
        phoneNumbertextField.delegate = self
        phoneNumbertextField.text = self.phoneNumber
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
