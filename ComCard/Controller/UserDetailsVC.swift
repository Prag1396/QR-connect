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

class UserDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var _phoneNumberdownloaded: String? = nil

    @IBOutlet weak var mytableview: UITableView!
    
    private var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mytableview.delegate = self
        mytableview.dataSource = self
     
        // Do any additional setup after loading the view.
        let userRef = DataService.instance.REF_BASE
        let userID = Auth.auth().currentUser?.uid
        userRef.child("users").child(userID!).observeSingleEvent(of: .value) { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            let fullName = dict?["FullName"] as? String
            let phoneNumber = dict?["PhoneNumber"] as? String
            let passportNumber = dict?["PassportNumber"] as? String
            self._phoneNumberdownloaded = phoneNumber
            let cardNumber = dict?["CardNumber"] as? String
            let user = User(fullname: fullName!, phoneNumber: phoneNumber!, cardNumber: cardNumber!, passportNumber: passportNumber!)
            self.users.append(user)
            self.mytableview.reloadData()
        }
    }
    
    @IBAction func deleteAccountPressed(_ sender: Any) {
        let currUser = Auth.auth().currentUser
        AuthService.instance.deleteUser(userID: (currUser?.uid)!)
        let alert = UIAlertController(title: "Account successfully deleted", message: "We hope to see you again soon", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            //perform segue that returns you to home screen
            self.performSegue(withIdentifier: "homebtnpressed", sender: Any.self)
        }))
        self.present(alert, animated: true, completion: nil)        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "datacell") as! ConfigureCell
        let user = users[indexPath.row]
        cell.updateUI(user: user)
        return cell
        
    }
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    @IBAction func homebtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "homebtnpressed", sender: Any.self)
    }
    
}
