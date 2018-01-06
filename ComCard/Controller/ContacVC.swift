//
//  ContacVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 12/30/17.
//  Copyright © 2017 Pragun Sharma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import MessageUI


class ContacVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, MFMessageComposeViewControllerDelegate{

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var creditCardTextField: UITextField!
    @IBOutlet weak var messageButton: buttonStyle!
    @IBOutlet weak var callButton: buttonStyle!
    
    private var _cardNumber: String? = nil
    private var _phoneNumber: String? = nil
    
    var cardNumber: String {
        get {
            return _cardNumber!
        } set {
            _cardNumber = newValue
        }
    }
    
    var phonenumber: String {
        get {
            return _phoneNumber!
        } set {
            _phoneNumber = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        background.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        creditCardTextField.delegate = self
        creditCardTextField.keyboardAppearance = .dark
        callButton.isUserInteractionEnabled = false
        messageButton.isUserInteractionEnabled = false
        // Do any additional setup after loading the view.

    }

    @objc func backgroundTapped() {
        view.endEditing(true)
    }
    
    func downloadRecord(withcardNumber cardNumber: String, downloadComplete: @escaping (_ status: Bool, _ error: String?) -> ()) {
        let userRef = DataService.instance.REF_USERS
        userRef.queryOrdered(byChild: "CardNumber").queryEqual(toValue: cardNumber).observeSingleEvent(of: .value) { (snapshot) in
            let isSnapshotexists = snapshot.exists()
            if (isSnapshotexists) {
                let array:NSArray = snapshot.children.allObjects as NSArray
                for child in array {
                    let snap = child as! DataSnapshot
                    if snap.value is NSDictionary {
                        let data: NSDictionary = (snap.value as? NSDictionary)!
                        if let phone = data.value(forKey: "PhoneNumber") {
                            self.phonenumber = phone as! String
                            downloadComplete(true, nil)
                        }
                    }
                }
                
            } else {
                downloadComplete(true, "Data not found")
            }
        }
        
    }
    
    func downloadDataandUpdateButtons() {
        downloadRecord(withcardNumber: (self.cardNumber)) { (status, error) in
            if (error != nil) {
                //handle Errors
                let alert = UIAlertController(title: "Warning", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.callButton.backgroundColor = UIColor(red: 77/255, green: 217/255, blue: 187/255, alpha: 1.0)
                self.messageButton.backgroundColor = UIColor(red: 77/255, green: 217/255, blue: 187/255, alpha: 1.0)
                self.messageButton.isUserInteractionEnabled = true
                self.callButton.isUserInteractionEnabled = true
                
            }
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.cardNumber = creditCardTextField.text!
        textField.resignFirstResponder()
        downloadDataandUpdateButtons()
        return true
    }

    @IBAction func callButtonPressed(_ sender: Any) {
        if let url = URL(string: "tel://\(self.phonenumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func messageButtonPressed(_ sender: Any) {
        if MFMessageComposeViewController.canSendText() {
            let message: MFMessageComposeViewController = MFMessageComposeViewController()
            message.messageComposeDelegate = self
            message.recipients = [self.phonenumber]
            message.body = "Hi, I am contacting you because I found you credit card. I was able to find your phone number through ComCard. Please contact me as soon as possible."
            self.present(message, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "WARNING", message: "Your device does not have the ability to send text messages", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    

}
