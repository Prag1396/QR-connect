//
//  OrderPlaceVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/16/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import MessageUI
import Firebase
import FirebaseAuth
import FirebaseDatabase
import PCLBlurEffectAlert

class OrderPlaceVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var zipcodeTextField: UITextField!
    @IBOutlet weak var countrytextfield: UITextField!
    @IBOutlet weak var statetextfield: UITextField!
    @IBOutlet weak var citytextfield: UITextField!
    @IBOutlet weak var streetaddresstextfield: UITextField!
    @IBOutlet weak var streetAddresstextfield2: UITextField!
    @IBOutlet weak var quantitytextfield: UITextField!
    
    var numberpickerview: UIPickerView = UIPickerView()
    var countryPickerView: UIPickerView = UIPickerView()
    var next_responder: UIResponder!
    var quantityArray: [Int] = Array(1...100)
    var countryArray = [String]()
    var countryDictReturned = [String(): String()]
    var obj: NSLocale = NSLocale()
    
    private var _country: String? = nil
    private var _state: String? = nil
    private var _city: String? = nil
    private var _street: String? = nil
    private var _street2: String? = nil
    private var _quantity: String? = nil
    private var _firstName: String? = nil
    private var _lastName: String? = nil
    private var _zipCode: String? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadUserName()
        self.setupOutlets()
        //Do any additional setup after loading the view.
        countryDictReturned = obj.countryArrayPopulate()
        countryArray = Array(countryDictReturned.values)
        countryArray.sort()
        countrytextfield.text = "United States"
    }
    
    func downloadUserName() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let userRef = DataService.instance.REF_USERS
        userRef.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                self._firstName = dict["FirstName"] as? String
                self._lastName = dict["lastName"] as? String
            }
        }
    }
    
    func setupOutlets() {
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        quantitytextfield.delegate = self
        quantitytextfield.keyboardAppearance = .dark
        quantitytextfield.tag = 7
        
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        countryPickerView.tag = 2
        countryPickerView.backgroundColor = UIColor.lightText
        countrytextfield.delegate = self
        countrytextfield.keyboardAppearance = .dark
        countrytextfield.tag = 5
        countrytextfield.inputView = countryPickerView
        
        statetextfield.delegate = self
        statetextfield.keyboardAppearance = .dark
        statetextfield.tag = 4
        
        citytextfield.delegate = self
        citytextfield.keyboardAppearance = .dark
        citytextfield.tag = 3
        
        streetaddresstextfield.delegate = self
        streetaddresstextfield.keyboardAppearance = .dark
        streetaddresstextfield.tag = 1
        
        streetAddresstextfield2.delegate = self
        streetAddresstextfield2.keyboardAppearance = .dark
        streetAddresstextfield2.tag = 2
        
        
        zipcodeTextField.delegate = self
        zipcodeTextField.keyboardAppearance = .dark
        zipcodeTextField.tag = 6
        
        
        numberpickerview.delegate = self
        numberpickerview.dataSource = self
        numberpickerview.tag = 1
        numberpickerview.backgroundColor = UIColor.lightText
        quantitytextfield.inputView = numberpickerview
        
 
    }
    
    @objc func backgroundTapped() {
        view.endEditing(true)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backbtnpressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return quantityArray.count
        }
        return countryArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            self.quantitytextfield.text = "\(row + 1)"
        } else {
            self.countrytextfield.text = countryArray[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return "\(row + 1)"
        }
        return countryArray[row]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag: Int = textField.tag + 1
        self.jumpToNextField(textfield: textField, withTag: nextTag)
        return false
    }
    
    func jumpToNextField(textfield: UITextField, withTag tag: Int) {
        
        next_responder = self.view.viewWithTag(tag)
        
        if (tag <= 7) {
            next_responder.becomeFirstResponder()
        } else {
            textfield.resignFirstResponder()
        }
        
    }
    
    func captureText() {
        guard let streetaddres = streetaddresstextfield.text, let streetadress2 = streetAddresstextfield2.text, let city = citytextfield.text, let state = statetextfield.text, let country = countrytextfield.text,let zipCode = zipcodeTextField.text, let quantity = quantitytextfield.text else {
            return
            }

            self._city = city
            self._street = streetaddres
            self._street2 = streetadress2
            self._state = state
            self._country = country
            self._zipCode = zipCode
            self._quantity = quantity
        
    }
    
    
    @IBAction func placeOrderbtnpressed(_ sender: Any) {
        
        captureText()
        
        if (self.streetaddresstextfield.text == nil || (self.streetaddresstextfield.text?.isEmpty)! ||
            self.citytextfield.text == nil || (self.citytextfield.text?.isEmpty)! || self.statetextfield.text == nil || (self.statetextfield.text?.isEmpty)! || self.countrytextfield.text == nil || (self.countrytextfield.text?.isEmpty)! || self.zipcodeTextField.text == nil || (self.zipcodeTextField.text?.isEmpty)! || self.quantitytextfield.text == nil || (self.quantitytextfield.text?.isEmpty)!) {
            
            let alert = PCLBlurEffectAlertController(title: "Warning", message: "All fields must be entered to place an order successfully", effect: UIBlurEffect(style: .light), style: .alert)
            alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                self.view.alpha = 1.0
            }))
            alert.configureAlert(alert: alert)
            self.view.alpha = 0.7
            alert.show()
            
        } else {
            self.storeData()
        }
    }
    
    func storeData() {
        if let fn = self._firstName, let ln = self._lastName, let ad1 = self._street, let ad2 = self._street2, let city = self._city, let state = self._state, let country = self._country, let zc = self._zipCode, let quant = self._quantity {
            DataService.instance.placeorder(firstname: fn, lastname: ln, addressline1: ad1, addressline2: ad2, city: city, state: state, country: country, zipCode: zc, quantity: quant, onOrderComplete: { (status, error) in
                if error != nil {
                    let alert = PCLBlurEffectAlertController(title: "Warning", message: error?.localizedDescription, effect: UIBlurEffect(style: .light), style: .alert)
                    alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.view.alpha = 1.0
                    }))
                    alert.configureAlert(alert: alert)
                    self.view.alpha = 0.7
                    alert.show()
                } else {
                    //Order Complete
                    self.postToSpreadsheet()
                }
            })
        }
    }
    
    func postToSpreadsheet() {
        HTTPService.instance.uploadtoSpreadsheet(firstName: self._firstName!, lastName: self._lastName!, street1: self._street!, street2: self._street2!, city: self._city!, state: self._state!, country: self._country!, zipcode: self._zipCode!, quantity: self._quantity!) { (status, error) in
            if error != nil {
                let alert = PCLBlurEffectAlertController(title: "Warning", message: error?.localizedDescription, effect: UIBlurEffect(style: .light), style: .alert)
                alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.view.alpha = 1.0
                }))
                alert.configureAlert(alert: alert)
                self.view.alpha = 0.7
                alert.show()
            } else {
                //Show confirmation
                print("Congrats order confirmed")
            }
        }
    }
    
}
