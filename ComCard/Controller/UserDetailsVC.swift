//
//  UserDetailsVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 12/31/17.
//  Copyright © 2017 Pragun Sharma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class UserDetailsVC: UIViewController, UITableViewDelegate {

    @IBOutlet weak var mytableview: UITableView!
    
    var fullName: String? = nil
    var phoneNumber: String? = nil
    var cardNumber: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextFields()
     

        
        // Do any additional setup after loading the view.

    }
    
    func setupTextFields() {
       
    }
    
    func downloadData(downloadComplete: @escaping (_ status: Bool)->()) {
        let userRef = DataService.instance.REF_BASE
        let userID = Auth.auth().currentUser?.uid
        userRef.child("users").child(userID!).observeSingleEvent(of: .value) { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            self.fullName = dict?["FullName"] as? String
            self.phoneNumber = dict?["PhoneNumber"] as? String
            self.cardNumber = dict?["CardNumber"] as? String
        }
        downloadComplete(true)
    }
 

    

    @IBAction func homebtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "homebtnpressed", sender: Any.self)
    }


}
