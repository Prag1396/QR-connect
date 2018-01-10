//
//  UserSigninVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/2/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class UserSigninVC: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    var next_Responder: UIResponder!
    private var _imageURL: String? = nil
    private var _userNameDownloaded = String()
    private var _passwordDownloaded = String()
    
    let userID = Auth.auth().currentUser?.uid
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.delegate = self
        userNameTextField.tag = 1
        userNameTextField.clearsOnBeginEditing = false
        passwordTextField.delegate = self
        passwordTextField.tag = 2
        userNameTextField.keyboardAppearance = .dark
        passwordTextField.keyboardAppearance = .dark
        passwordTextField.clearsOnBeginEditing = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        background.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        self.downLoadUsernameandPassword { (status) in
            if(status == true) {
                print(self._userNameDownloaded)
                let data = (self._userNameDownloaded).data(using: String.Encoding.ascii, allowLossyConversion: false)
                self.uploadQRCode(uid: (self.userID)!, data: data!)
            }
        }
    }
    
    func downLoadUsernameandPassword(onusernameDownloadComplete: @escaping (_ status: Bool)->()) {
        let userRef = DataService.instance.REF_BASE
        let privateRef = DataService.instance.REF_PVT
        
        //Get Username
        userRef.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            self._userNameDownloaded = (dict?["PhoneNumber"] as? String)!
            onusernameDownloadComplete(true)
            print("PRAGUN: \(self._userNameDownloaded)")
        })
        //Get Password
        privateRef.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            self._passwordDownloaded = (dict?["Passcode"] as! String)
        })
        
    }
    
    
    func uploadQRCode(uid: String, data: Data) {
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        let imageToUpload = convertToUIImage(c_image: (filter?.outputImage)!)
        StorageService.instance.uploadImage(withuserID: userID!, image: imageToUpload) { (status, error, url) in
            if (error != nil) {
                let alert = UIAlertController(title: "Warning", message: error.debugDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                print("Uploaded Successfully")
                self._imageURL = "\(url!)"
                //set destination image url
                ImageURLStruct.imageURL = self._imageURL!
                print(self._imageURL!)
                
            }

        }
    }
    
    func convertToUIImage(c_image: CIImage) -> UIImage {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(c_image, from: c_image.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
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

    @IBAction func signInBtnTapped(_ sender: Any) {
        
        if userNameTextField.text != nil && passwordTextField.text != nil {

            if(self._userNameDownloaded == userNameTextField.text && self._passwordDownloaded == passwordTextField.text) {
                //Successfull sign in
                self.performSegue(withIdentifier: "signinsuccessfull", sender: Any.self)
            }
            else if(self.userNameTextField.text != self._userNameDownloaded) {

                let alert = UIAlertController(title: "Warning", message: "Username does not exists. Please try signing up", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Warning", message: "Username and password do not match", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
 
    }
    
}
