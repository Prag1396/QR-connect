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
import PCLBlurEffectAlert

class SettingsVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var requestQRStickerslabel: UILabel!
    @IBOutlet weak var changePwdLabel: UILabel!
    @IBOutlet weak var viewProfileLabel: UILabel!
    @IBOutlet weak var contactlabel: UILabel!
    var contactStore = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(fetchContact))
        contactlabel.addGestureRecognizer(tap)
        tap.delegate = self
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(loadProfile))
        viewProfileLabel.addGestureRecognizer(tap2)
        tap2.delegate = self
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(loadchangepwdvc))
        changePwdLabel.addGestureRecognizer(tap3)
        tap3.delegate = self
        
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(loadordervc))
        requestQRStickerslabel.addGestureRecognizer(tap4)
        tap4.delegate = self
        
        
    }
    
    @objc func loadordervc() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controllertoPresent = storyBoard.instantiateViewController(withIdentifier: "ordervc") as? OrderPlaceVC
        if let vc = controllertoPresent {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func loadchangepwdvc() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controllertoPresent = storyBoard.instantiateViewController(withIdentifier: "changepwdvc") as? ChangePasswordVC
        if let vc = controllertoPresent {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func loadProfile() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controllertoPresent = storyBoard.instantiateViewController(withIdentifier: "userDetailsVC") as? UserDetailsVC
        if let vc = controllertoPresent {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func backbtnpressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func fetchContact() {
        self.requestAccess { (granted) in
            if granted {
                //fetch contacts
                print("Granted")
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let controllertoPresent = storyBoard.instantiateViewController(withIdentifier: "tocontacts") as? ContactsInviteVC
                if let cp = controllertoPresent {
                    self.present(cp, animated: true, completion: nil)
                }
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

        let alert = PCLBlurEffectAlertController(title: "Caution", message: "This app requires access to Contacts to proceed. Would you like to open settings and grant permission to contacts?", effect: UIBlurEffect(style: .light), style: .alert)
        alert.addAction(PCLBlurEffectAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
            self.view.alpha = 1.0
        }))
        alert.addAction(PCLBlurEffectAlertAction(title: "Open Settings", style: .default, handler: { (action) in
            completionHandler(true)
            self.view.alpha = 1.0
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        
        alert.configureAlert(alert: alert)
        self.view.alpha = 0.7
        alert.show()
        
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
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let controllertoPresent = storyBoard.instantiateViewController(withIdentifier: "tocontacts") as? ContactsInviteVC
                if let cp = controllertoPresent {
                    self.present(cp, animated: true, completion: nil)
                }
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
}
