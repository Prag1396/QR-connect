//
//  SettingsVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/7/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func inviteContactPressed(_ sender: Any) {
        
    }
    
    @IBAction func requestQRStickerPressed(_ sender: Any) {
        
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        //Logout user
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let controllerToPresent = storyBoard.instantiateViewController(withIdentifier: "homescreen") as? HomeScreenVC
            self.present(controllerToPresent!, animated: true, completion: nil)
        } catch let signouterror as NSError {
            print("Error signing out: \(signouterror)")
        }
    }
    
    @IBAction func changePasswordBtn(_ sender: Any) {
        
    }
    
    @IBAction func reportIsuueBtnpressed(_ sender: Any) {
        
    }
    
    @IBAction func clearChat(_ sender: Any) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        DataService.instance.REF_USERMESSAGES.child(uid).removeValue { (error, ref) in
            if error != nil {
                print("Unable to delete messages")
            }
        }
        
    }
    
}
