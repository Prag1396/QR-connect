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
import Contacts

class SettingsVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var contactlabel: UILabel!
    var contactStore = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(fetchContact))
        contactlabel.addGestureRecognizer(tap)
        tap.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func fetchContact() {
        self.requestAccess { (granted) in
            if granted {
                //fetch contacts
                print("Granted")
                self.performSegue(withIdentifier: "tocontacts", sender: Any.self)
            } else {
                print("Denied")
            }
        }
    }
    
    func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completionHandler(true)
        case .denied:
            showSettingsAlert(completionHandler)
        case .restricted, .notDetermined:
            contactStore.requestAccess(for: .contacts) { granted, error in
                if granted {
                    completionHandler(true)
                } else {
                    DispatchQueue.main.async {
                        self.showSettingsAlert(completionHandler)
                    }
                }
            }
        }
    }
    
    private func showSettingsAlert(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: "This app requires access to Contacts to proceed. Would you like to open settings and grant permission to contacts?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            completionHandler(false)
        })
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
            completionHandler(false)
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        present(alert, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func inviteContactPressed(_ sender: Any) {
        self.requestAccess { (granted) in
            if granted {
                //fetch contacts
                print("Granted")
                self.performSegue(withIdentifier: "tocontacts", sender: Any.self)
            } else {
                print("Denied")
            }
        }
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
