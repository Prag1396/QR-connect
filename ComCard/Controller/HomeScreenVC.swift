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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }
    
    @IBAction func generateQRCodeBtnPressed(_ sender: Any) {
        //Check if user authenticated
        //If yes then load usersignin if not authenticated then load sign up screen
        if Auth.auth().currentUser?.uid == nil {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let controllerToPresent = storyBoard.instantiateViewController(withIdentifier: "userSignin") as? UserSigninVC
            self.present(controllerToPresent!, animated: true, completion: nil)
        } else {
            //load sign in
            print(Auth.auth().currentUser?.uid ?? String())
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let controllerToPresent = storyBoard.instantiateViewController(withIdentifier: "tabbarvc") as? UITabBarController
            self.present(controllerToPresent!, animated: true, completion: nil)
        }
    }
    
    @IBAction func contactBtnPressed(_ sender: Any) {
        //Check if user authenticated
        //If yes then load contactVC if not authenticated then load sign up screen
        if((Auth.auth().currentUser) != nil) {
            performSegue(withIdentifier: "userverified", sender: Any.self)
        }
        
        else {
            //Get UserSign up has storyboard and load it
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let controllerToPresent = storyBoard.instantiateViewController(withIdentifier: "userSignin") as? UserSigninVC
            self.present(controllerToPresent!, animated: true, completion: nil)
            
        }
    }
    
    
}

