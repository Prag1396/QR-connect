//
//  ChatVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/21/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth



class ChatVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var userfirstname: UILabel!
    @IBOutlet weak var messagefield: TextFieldStyle!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var sendbtn: UIButton!
    @IBOutlet weak var mycollectionview: UICollectionView!
    
    private var _fullName: String? = nil
    private var _recipientUID: String? = nil
    private var _currentUID = Auth.auth().currentUser?.uid
    
    var fullname: String {
        get {
            return _fullName!
        } set {
           self._fullName = newValue
        }
    }
    
    var recipientUID: String {
        get {
            return _recipientUID!
        } set {
            self._recipientUID = newValue
        }
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        messagefield.delegate = self
        messagefield.keyboardAppearance = .dark
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        background.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        self.userfirstname.text = self.fullname
        // Do any additional setup after loading the view.
        
        
    }

    @objc func backgroundTapped() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func sendbtnpressed(_ sender: Any) {
        if(messagefield.text != nil) {
            let data = ["message": messagefield.text!]
            DataService.instance.uploadMessage(senderuid: (Auth.auth().currentUser?.uid)!, recipientUID: recipientUID, message: data)
            
        }
    }
    
    
    

}
