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
            let cardNumber = dict?["CardNumber"] as? String
            let user = User(fullname: fullName!, phoneNumber: phoneNumber!, cardNumber: cardNumber!)
            self.users.append(user)
            self.mytableview.reloadData()
        }
    }
    
    @IBAction func deleteAccountPressed(_ sender: Any) {
        let currUser = Auth.auth().currentUser
        print(currUser?.uid ?? String())
        currUser?.delete(completion: { (error) in
            if((error) != nil) {
                let alert = UIAlertController(title: "Unable to delete account", message: "This operation is sensitive and requires recent authentication", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                print(error.debugDescription)
                self.present(alert, animated: true, completion: nil)
            }
        })
        
    }
    
    @IBAction func reauthenticatePressed(_ sender: Any) {
        
        
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
