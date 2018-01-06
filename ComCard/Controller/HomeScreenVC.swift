//
//  ViewController.swift
//  ComCard
//
//  Created by Pragun Sharma on 12/30/17.
//  Copyright © 2017 Pragun Sharma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class HomeScreenVC: UIViewController {

    var currentUser: FirebaseAuth.User? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Check if user authenticated
        //If yes then load contactVC if not authenticated then load sign up screen
        currentUser = Auth.auth().currentUser
    }
    

    @IBAction func contactBtnPressed(_ sender: Any) {
        if((currentUser) != nil) {
            performSegue(withIdentifier: "userverified", sender: Any.self)
        } else {
            //Get UserSign up has storyboard and load it
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let controllerToPresent = storyBoard.instantiateViewController(withIdentifier: "userSignUp")
            self.present(controllerToPresent, animated: true, completion: nil)
            
        }
    }
}

