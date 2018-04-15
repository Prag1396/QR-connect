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
    
    var numberpickerview: UIPickerView = UIPickerView()
    var countryPickerView: UIPickerView = UIPickerView()
    var statePickerView: UIPickerView = UIPickerView()
    var next_responder: UIResponder!

    
    let allStates = [ "AK","AL","AR","AS","AZ","CA","CO","CT","DC","DE","FL","GA","GU","HI","IA","ID",
                      "IL","IN","KS","KY","LA","MA","MD","ME","MI","MN","MO","MS","MT","NC","ND","NE",
                      "NH","NJ","NM","NV","NY","OH","OK","OR","PA","PR","RI","SC","SD","TN","TX","UT",
                      "VA","VI","VT","WA","WI","WV","WY"]

    
    private var _country: String? = nil
    private var _state: String? = nil
    private var _city: String? = nil
    private var _street: String? = nil
    private var _street2: String? = nil
    private var _firstName: String? = nil
    private var _lastName: String? = nil
    private var _zipCode: String? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadUserName()
        self.setupOutlets()
        UIApplication.shared.applicationIconBadgeNumber = 0

        countrytextfield.text = "United States"
        countrytextfield.isUserInteractionEnabled = false
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

        countrytextfield.delegate = self
        countrytextfield.keyboardAppearance = .dark
        countrytextfield.tag = 5
        
        statePickerView.delegate = self
        statePickerView.dataSource = self
        statePickerView.tag = 3
        statePickerView.backgroundColor = UIColor.lightText
        
        
        statetextfield.delegate = self
        statetextfield.keyboardAppearance = .dark
        statetextfield.tag = 4
        statetextfield.inputView = statePickerView
        
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
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        
        return allStates.count

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        self.statetextfield.text = allStates[row]

    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return allStates[row]
      

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
        guard let streetaddres = streetaddresstextfield.text, let streetadress2 = streetAddresstextfield2.text, let city = citytextfield.text, let state = statetextfield.text, let country = countrytextfield.text,let zipCode = zipcodeTextField.text else {
            return
            }

            self._city = city
            self._street = streetaddres
            self._street2 = streetadress2
            self._state = state
            self._country = country
            self._zipCode = zipCode
        
    }
    
    
    @IBAction func placeOrderbtnpressed(_ sender: Any) {
        
        captureText()

        if (self.streetaddresstextfield.text == nil || (self.streetaddresstextfield.text?.isEmpty)! ||
            self.citytextfield.text == nil || (self.citytextfield.text?.isEmpty)! || self.statetextfield.text == nil || (self.statetextfield.text?.isEmpty)! || self.countrytextfield.text == nil || (self.countrytextfield.text?.isEmpty)! || self.zipcodeTextField.text == nil || (self.zipcodeTextField.text?.isEmpty)!) {
            
            let alert = PCLBlurEffectAlertController(title: "Warning", message: "All fields must be entered to place an order successfully", effect: UIBlurEffect(style: .light), style: .alert)
            alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.alpha = 1.0
                })
            }))
            alert.configureAlert(alert: alert)
            self.view.alpha = 0.7
            alert.show()
            
        }

        
        else if (((self.zipcodeTextField.text?.count)! != 5)) {
            let alert = PCLBlurEffectAlertController(title: "Warning", message: "Invalide Zipcode entered", effect: UIBlurEffect(style: .light), style: .alert)
            alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.alpha = 1.0
                })
            }))
            alert.configureAlert(alert: alert)
            self.view.alpha = 0.7
            alert.show()
        }
        else {
            self.storeData()
        }
        
    }
    
    func storeData() {
        if let fn = self._firstName, let ln = self._lastName, let ad1 = self._street, let ad2 = self._street2, let city = self._city, let state = self._state, let country = self._country, let zc = self._zipCode {
            DataService.instance.placeorder(firstname: fn, lastname: ln, addressline1: ad1, addressline2: ad2, city: city, state: state, country: country, zipCode: zc, onOrderComplete: { (status, error) in
                if error != nil {
                    let alert = PCLBlurEffectAlertController(title: "Warning", message: error?.localizedDescription, effect: UIBlurEffect(style: .light), style: .alert)
                    alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                        UIView.animate(withDuration: 0.5, animations: {
                            self.view.alpha = 1.0
                        })
                    }))
                    alert.configureAlert(alert: alert)
                    self.view.alpha = 0.7
                    alert.show()
                
                    
                } else {
                    //Order Complete
                    let alert = PCLBlurEffectAlertController(title: "Congratulations!", message: "You have successfully placed the order. A confirmation has been sent to your email with order details", effect: UIBlurEffect(style: .light), style: .alert)
                    alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                        UIView.animate(withDuration: 0.5, animations: {
                            self.view.alpha = 1.0
                        })
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let controllerToPresent = storyBoard.instantiateViewController(withIdentifier: "homescreen") as? HomeScreenVC
                        if let cp = controllerToPresent {
                            self.present(cp, animated: true, completion: nil)
                        }
                        
                        
                    }))
                    alert.configureAlert(alert: alert)
                    alert.configure(titleColor: UIColor(red: 77/255, green: 225/255, blue: 158/255, alpha: 1.0))
                    self.view.alpha = 0.7
                    alert.show()
                    
                }
            })
        }
    }
    
}
