//
//  NameCaptureVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 1/18/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class NameCaptureVC: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {

    @IBOutlet weak var donebtn: UIButton!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var background: UIImageView!
    
    var next_responder: UIResponder!
    var isReadytoPerformSegue: Bool!
    var data: [String] = ["Email", "In-App Message"]
    
    private var _imageURL: String? = nil
    private var _phonenumber: String? = nil
    private var _email: String? = nil
    private var _password: String? = nil
    private var _firstName: String? = nil
    private var _lastName: String? = nil
    
    var phoneNumber: String {
        get {
            return _phonenumber!
        }
        set {
            self._phonenumber = newValue
        }
    }
    
    var email: String {
        get {
            return _email!
        } set {
            self._email = newValue
        }
    }
    
    var password: String {
        get {
            return _password!
        }
        set {
            self._password = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        background.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        firstName.delegate = self
        lastName.delegate = self
        firstName.keyboardAppearance = .dark
        lastName.keyboardAppearance = .dark
        firstName.tag = 1
        lastName.tag = 2
        
        // Do any additional setup after loading the view.
    }

    
    @objc func backgroundTapped() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag: Int = textField.tag + 1

        self.jumpToNextField(textfield: textField, withTag: nextTag)
        return false
    }
    
    func jumpToNextField(textfield: UITextField, withTag tag: Int) {
        
        next_responder = self.view.viewWithTag(tag)
        
        if (tag <= 2) {
            next_responder.becomeFirstResponder()
        } else {
            textfield.resignFirstResponder()
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.donebtn.alpha = 0.6
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(self.isReadytoPerformSegue == true && firstName.text?.isEmpty == false && lastName.text?.isEmpty == false) {
            self.donebtn.alpha = 1.0
        }
        
    }
    
    func captureText() {
        _firstName = firstName.text!
        _lastName = lastName.text!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func donebtnpressed(_ sender: Any) {
        captureText()
        if ((firstName.text?.isEmpty)! || (lastName.text?.isEmpty)!) {
            //Present Alert
            let alert = UIAlertController(title: "Warning", message: "Please enter your full name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            //Create DB User
            AuthService.instance.registerUser(withEmail: self.email, andPassword: self.password, firstName: self._firstName!, lastname: self._lastName!, phonenumber: self.phoneNumber, userCreationComplete: { (userID, success, registrationError)  in
                    if success {
                        AuthService.instance.loginUser(withEmail: self.email, andPassword: self.password, loginComplete: { (success, nil) in
                            
                            let data = (self.email + " " + self._firstName!).data(using: String.Encoding.ascii, allowLossyConversion: false)
                            self.uploadQRCode(uid: (userID)!, data: data!)
                            self.performSegue(withIdentifier: "loaduserdetails", sender: Any.self)
                            print("Successfully registered user")
                        })
                    } else {
                        print(String(describing: registrationError?.localizedDescription))
                    }
                })

        }
    }
    
    func convertToUIImage(c_image: CIImage) -> UIImage {
        let context:CIContext = CIContext.init(options: nil)
        let transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        let img = c_image.transformed(by: transform)
        let cgImage:CGImage = context.createCGImage(img, from: c_image.extent)!
        
        let image:UIImage = UIImage.init(cgImage: cgImage)
        //Change size
        let scaledImage = image.scaleUIImageToSize(image: image, size: CGSize(width: 120, height: 120))
        return scaledImage
    }
    
    
    func uploadQRCode(uid: String, data: Data) {
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        
        let imageToUpload = convertToUIImage(c_image: (filter?.outputImage)!)
        StorageService.instance.uploadImage(withuserID: uid, image: imageToUpload) { (status, error, url) in
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
}
