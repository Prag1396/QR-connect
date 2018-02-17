//
//  OrderPlaceVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/16/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit

class OrderPlaceVC: UIViewController {

    @IBOutlet weak var countrytextfield: UITextField!
    @IBOutlet weak var statetextfield: UITextField!
    @IBOutlet weak var citytextfield: UITextField!
    @IBOutlet weak var streetaddresstextfield: UITextField!
    @IBOutlet weak var lastnametextfield: UITextField!
    @IBOutlet weak var firstnamelabel: UITextField!
    @IBOutlet weak var qrcodevaluepickerview: UIPickerView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backbtnpressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
