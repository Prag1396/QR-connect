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

struct ImageURLStruct {
    private static var _imageURL: String? = nil
    
    static var imageURL: String {
        get {
            return _imageURL!
        } set {
            _imageURL = newValue
        }
    }
}

class UserDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
        userRef.child("users").child(userID!).observeSingleEvent(of: .value) { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            let fullName = dict?["FullName"] as? String
            let phoneNumber = dict?["PhoneNumber"] as? String
            let email = dict?["Email"] as? String
            self._phoneNumberdownloaded = phoneNumber
            self._fullNameDownloaded = fullName
            self._emailDownloaded = email
            let cardNumber = dict?["CardNumber"] as? String
            let user = User(fullname: fullName!, phoneNumber: phoneNumber!, cardNumber: cardNumber!, email: email!)
            self.users.append(user)
            self.mytableview.reloadData()
        }
    }
    
    @IBAction func buildQRCodePressed(_ sender: Any) {
        
       //Download QRCode
        let downloadimageURL: StorageReference = Storage.storage().reference(forURL: ImageURLStruct.imageURL)
        downloadimageURL.downloadURL { (url, error) in
            if (error != nil) {
                print(error.debugDescription)
            } else {

                StorageService.instance.downloadImage(withURL: url!, downloadCompleteImage: { (status, error, data)  in
                    if (error != nil) {
                        //present alert
                        print(error.debugDescription)
                    } else {
                        //Present sub view with the options of saving the image or emailing it
                        DispatchQueue.main.async {
                            let imageData = UIImage(data: data!)
                            self.showAlertView(image: imageData!)
                        }
                        
                    }
                })
            }
        }
 
    }
    
    func showAlertView(image: UIImage) {
        let alertView = UIAlertController(title: "Comcard", message: "QRCode has been downloaded", preferredStyle: .alert)
        
        //Add Image
        alertView.addImage(image: image)
        
        alertView.addAction(UIAlertAction(title: "Save to Photos", style: .default, handler: { (action) in
            self.saveToPhotosPressed()
        }))
        alertView.addAction(UIAlertAction(title: "Email", style: .default, handler: { (action) in
            self.emailPressed()
        }))
        
        self.present(alertView, animated: true, completion: nil)
        
    }
    
    func emailPressed() {
        
    }
    
    func saveToPhotosPressed() {
        
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
