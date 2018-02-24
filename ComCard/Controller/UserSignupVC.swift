//
//  LoginVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 12/30/17.
//  Copyright © 2017 Pragun Sharma. All rights reserved.
//

import UIKit
import PCLBlurEffectAlert

struct CurrentLength {
    static var currLength: Int = 0
}


class UserSignupVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var phoneNumberLabel: UITextField!
    @IBOutlet weak var phoneNumberAlreaduInUse: UILabel!
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var country_extension_textlabel: UITextField!
    
    private var _plus = "+"
    private var _phoneNumberExt: String? = nil
    private var _fullPhoneNumber: String? = nil
    private var _phoneNumber: String? = nil
    var next_responder: UIResponder!
    var isReadytoPerformSegue: Bool!
    
    var countryNames = [String()]
    var countryDictReturned = [String(): String()]
    
    var pickerView: UIPickerView = UIPickerView()
    var obj: NSLocale = NSLocale()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        background.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        setupOutlets()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.lightText
        country_extension_textlabel.inputView = pickerView
        countryDictReturned = obj.countryArrayPopulate()
        countryNames = Array(countryDictReturned.values)
        sortCountryArray()
        setupDeafultValueForPickerView()
        self._phoneNumberExt = _plus + "1"
        isReadytoPerformSegue = true
        
    }

    func sortCountryArray() {
        //sort country names
        countryNames.sort()
    }
    
    func setupDeafultValueForPickerView() {
        country_extension_textlabel.text = convertToFlag(country: "US")
    }
    
    @objc func backgroundTapped() {
        view.endEditing(true)
    }
    
    func setupOutlets() {
        
        phoneNumberLabel.delegate = self
        phoneNumberLabel.tag = 1
        phoneNumberLabel.clearsOnBeginEditing = false
        phoneNumberLabel.keyboardAppearance = .dark
        
        country_extension_textlabel.tintColor = UIColor.clear
        
    }
    
    @IBAction func backbtnpressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func alreadyamemberBtnPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controllerToPresent = storyBoard.instantiateViewController(withIdentifier: "userSignin") as? UserSigninVC
        self.present(controllerToPresent!, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

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
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return countryNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let countryCode = countryDictReturned.someKey(forValue: countryNames[row])
        if var cc = countryCode {
            cc.removeFirst()
            country_extension_textlabel.text = convertToFlag(country: cc)
            //Get country code extension for phone number
            self._phoneNumberExt =  _plus + cc.getCountryCallingCode(countryRegionCode: cc)
        }
    }
    
    func convertToFlag(country: String) -> String {
        
        let base: UInt32 = 127397
        return country.unicodeScalars.flatMap { String.init(UnicodeScalar(base + $0.value)!) }.joined()
    }
    
    @IBAction func connectBtnPressed(_ sender: Any) {
        captureText()
        if ((phoneNumberLabel.text?.isEmpty)!) {
            //ADD CUSTOM ALERT
            
            let alert = PCLBlurEffectAlertController(title: "Warning", message: "Please enter your contact number", effect: UIBlurEffect(style: .light), style: .alert)
            alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                self.view.alpha = 1.0
            }))
            alert.configureAlert(alert: alert)
            self.view.alpha = 0.7
            alert.show()

        }
        else {
            //Perform segue to verification
            performSegue(withIdentifier: "connectPressed", sender: (Any).self)
        }
   
    }
    
    func captureText() {
        _phoneNumber = phoneNumberLabel.text!.trimmingCharacters(in: .whitespaces)
        self._fullPhoneNumber = _phoneNumberExt! + _phoneNumber!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "connectPressed") {
            if let destination = segue.destination as? ConfirmLoginVC {
                if phoneNumberLabel.text != nil {
                    destination.phoneNumber = self._fullPhoneNumber!
                }
            }
            
        }
    }

}
