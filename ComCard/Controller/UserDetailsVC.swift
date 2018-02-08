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

    @IBOutlet weak var fullnameLabel: UILabel!
    private var _phoneNumberdownloaded: String? = nil
    private var _fullNameDownloaded: String? = nil
    private var _emailDownloaded: String? = nil
    
    
    @IBOutlet weak var mytableview: UITableView!
    
    private var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mytableview.delegate = self
        mytableview.dataSource = self
        
        // Do any additional setup after loading the view.
        let userRef = DataService.instance.REF_BASE
        let userID = Auth.auth().currentUser?.uid
        userRef.child("pvtdata").child(userID!).observeSingleEvent(of: .value) { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            self._emailDownloaded = dict?["Email"] as? String
            self._phoneNumberdownloaded = dict?["PhoneNumber"] as? String
            self.downloadFirstnameandImageUrl(onfirstnamedownloadComplete: { (status) in
                if status == true {
                    let user = User(phoneNumber: self._phoneNumberdownloaded!, email: self._emailDownloaded!)
                    self.users.append(user)
                    DispatchQueue.main.async {
                        self.mytableview.reloadData()
                        self.fullnameLabel.text = self._fullNameDownloaded
                    }
                }
            })
        }
    }
    
    func downloadFirstnameandImageUrl(onfirstnamedownloadComplete: @escaping (_ status: Bool)->()) {
        let userRef = DataService.instance.REF_BASE
        let userID = Auth.auth().currentUser?.uid
        
        userRef.child("users").child(userID!).observeSingleEvent(of: .value) { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            let fullName = dict?["FirstName"] as? String
            self._fullNameDownloaded = fullName
            
            onfirstnamedownloadComplete(true)
        }
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
    
}
