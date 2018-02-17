//
//  OrderPlaceVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/16/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class OrderPlaceVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var zipcodeTextField: UITextField!
    @IBOutlet weak var countrytextfield: UITextField!
    @IBOutlet weak var statetextfield: UITextField!
    @IBOutlet weak var citytextfield: UITextField!
    @IBOutlet weak var streetaddresstextfield: UITextField!
    @IBOutlet weak var lastnametextfield: UITextField!
    @IBOutlet weak var firstnamelabel: UITextField!
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
    private var _quantity: String? = nil
    private var _firstName: String? = nil
    private var _lastName: String? = nil
    private var _zipCode: String? = nil
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupOutlets()
        // Do any additional setup after loading the view.
        countryDictReturned = obj.countryArrayPopulate()
        countryArray = Array(countryDictReturned.values)
        countryArray.sort()
        countrytextfield.text = "United States"
    }
    
    func setupOutlets() {
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        quantitytextfield.delegate = self
        quantitytextfield.keyboardAppearance = .dark
        quantitytextfield.tag = 8
        
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        countryPickerView.tag = 2
        countryPickerView.backgroundColor = UIColor.lightText
        countrytextfield.delegate = self
        countrytextfield.keyboardAppearance = .dark
        countrytextfield.tag = 6
        countrytextfield.inputView = countryPickerView
        
        statetextfield.delegate = self
        statetextfield.keyboardAppearance = .dark
        statetextfield.tag = 5
        
        citytextfield.delegate = self
        citytextfield.keyboardAppearance = .dark
        citytextfield.tag = 4
        
        streetaddresstextfield.delegate = self
        streetaddresstextfield.keyboardAppearance = .dark
        streetaddresstextfield.tag = 3
        
        lastnametextfield.delegate = self
        lastnametextfield.keyboardAppearance = .dark
        lastnametextfield.tag = 2
        
        firstnamelabel.delegate = self
        firstnamelabel.keyboardAppearance = .dark
        firstnamelabel.tag = 1
        
        zipcodeTextField.delegate = self
        zipcodeTextField.keyboardAppearance = .dark
        zipcodeTextField.tag = 7
        
        
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
        
        if (tag <= 8) {
            next_responder.becomeFirstResponder()
        } else {
            textfield.resignFirstResponder()
        }
        
    }
    
    func captureText() {
        guard let firstName = firstnamelabel.text, let lastName = lastnametextfield.text, let streetaddres = streetaddresstextfield.text, let city = citytextfield.text, let state = statetextfield.text, let country = countrytextfield.text,let zipCode = zipcodeTextField.text, let quantity = quantitytextfield.text else {
            //show error
            let alert = UIAlertController(title: "Warning", message: "All fields must be entered to successfully place an order", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
            }
            self._firstName = firstName
            self._lastName = lastName
            self._city = city
            self._street = streetaddres
            self._state = state
            self._country = country
            self._zipCode = zipCode
            self._quantity = quantity
        
    }
    
    
    @IBAction func placeOrderbtnpressed(_ sender: Any) {
        captureText()
        print(_zipCode ?? String())
    }
    
}
