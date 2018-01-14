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
import IQKeyboardManagerSwift
import AVFoundation

class ContacVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, MFMessageComposeViewControllerDelegate, AVCaptureMetadataOutputObjectsDelegate{

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var creditCardTextField: UITextField!
    @IBOutlet weak var border: UIImageView!
    
    var session = AVCaptureSession()
    private var _cardNumber: String? = nil
    private var _phoneNumber: String? = nil
    private var _email: String? = nil
    private var _fullName: String? = nil
    
    var video = AVCaptureVideoPreviewLayer()
    
    var next_responder: UIResponder!

    var cardNumber: String {
        get {
            return _cardNumber!
        } set {
            _cardNumber = newValue
        }
    }
    
    var fullName: String {
        get {
            return _fullName!
        } set {
            _fullName = newValue
        }
    }
    
    var phonenumber: String {
        get {
            return _phoneNumber!
        } set {
            _phoneNumber = newValue
        }
    }
    
    var email: String {
        get {
            return _email!
        } set {
            _email = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(textField: )))
        background.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        creditCardTextField.tag = 1
        creditCardTextField.delegate = self
        creditCardTextField.keyboardAppearance = .dark

        // Do any additional setup after loading the view.
        IQKeyboardManager.sharedManager().toolbarDoneBarButtonItemText = "Continue"
        
        creditCardTextField.addDoneOnKeyboardWithTarget(self, action: #selector(handleDoneActionForCard))
        
        
    }

    @objc func handleDoneActionForCard() {
        self.cardNumber = creditCardTextField.text!
        downloadDataandUpdateButtons(textField: creditCardTextField)
        view.endEditing(true)
    }
    
    
    @IBAction func scanQRCodepressed(_ sender: Any) {
        //Create Session
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        } catch {
            print("ERROR: Input not working")
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        self.view.bringSubview(toFront: border)
        session.startRunning()
        
        
    }
    
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //If we have something
        if metadataObjects.isEmpty == false  {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {
                    print(object.stringValue ?? String())
                    setData(phone: object.stringValue!)
                    //dismiss the sublayer
                    self.view.sendSubview(toBack: border)
                    video.removeFromSuperlayer()
                    session.stopRunning()
                    
                }
            }
            
        }
    }
    
    func setData(phone: String) {
        self.phonenumber = phone
        downloadDetails(ofperson: self.phonenumber) { (status, errmsg) in
            if status == true {
               print(self.fullName)
               print(self.email)
            } else if status == false {
                print(errmsg!)
            }
        }
    
    }
    
    func downloadDetails(ofperson phonenumber: String, ondownloadComplete: @escaping (_ status: Bool,_ error: String?)->()) {
        let userRef = DataService.instance.REF_USERS
        userRef.queryOrdered(byChild: "PhoneNumber").queryEqual(toValue: self.phonenumber).observeSingleEvent(of: .value) { (snapshot) in
            let isSnapshotexists = snapshot.exists()
            if(isSnapshotexists) {
                let array:NSArray = snapshot.children.allObjects as NSArray
                for child in array {
                    let snap = child as! DataSnapshot
                    if snap.value is NSDictionary {
                        let data: NSDictionary = (snap.value as? NSDictionary)!
                        if let fullname = data.value(forKey: "FullName") {
                            self.fullName = fullname as! String
                        }
                        if let email = data.value(forKey: "Email") {
                            self.email = email as! String
                        }
                        ondownloadComplete(true, nil)
                    }
                }
                
            } else {
                ondownloadComplete(false, "Did not find any data")
            }
        }
    }
    
    @objc func backgroundTapped(textField: UITextField) {
        view.endEditing(true)
        if (creditCardTextField.text != nil) {
            creditCardTextField.endEditing(true)
        }
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
    

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.tag == 1) {
            self.cardNumber = creditCardTextField.text!
        }
        
        textField.resignFirstResponder()
        downloadDataandUpdateButtons(textField: textField)
    }
    
    
    func downloadDataandUpdateButtons(textField: UITextField) {
        if (textField.tag == 1) {
        downloadRecord(withcardNumber: (self.cardNumber)) { (status, error) in
            if (error != nil) {
                //handle Errors
                let alert = UIAlertController(title: "Warning", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                //Present View
            }
        }
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.tag == 1) {
            self.cardNumber = creditCardTextField.text!
        }
        
        textField.resignFirstResponder()
        downloadDataandUpdateButtons(textField: textField)
        return true
    }
    
    /*
    @IBAction func callButtonPressed(_ sender: Any) {
        if let url = URL(string: "tel://\(self.phonenumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }
    }
    */
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    @IBAction func messageButtonPressed(_ sender: Any) {
        if MFMessageComposeViewController.canSendText() {
            let message: MFMessageComposeViewController = MFMessageComposeViewController()
            message.messageComposeDelegate = self
            message.recipients = [self.phonenumber]
            if (self.creditCardTextField.text != nil) {
                message.body = "Hi, I am contacting you because I found your credit card. I was able to find your phone number through ComCard. Please contact me as soon as possible."
            }
            self.present(message, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "WARNING", message: "Your device does not have the ability to send text messages", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    */
    

}
