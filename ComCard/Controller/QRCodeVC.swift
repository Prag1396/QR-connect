//
//  QRCodeVC.swift
//  ComCard
//
//  Created by Pragun Sharma on 2/7/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import Photos
import MessageUI

class QRCodeVC: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var qrcodeimage: imageStyle!
    
    private var _imageURLDownloaded: String? = nil
    private var _emailDownloaded: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userRef = DataService.instance.REF_BASE
        let userID = Auth.auth().currentUser?.uid
        userRef.child("pvtdata").child(userID!).observeSingleEvent(of: .value) { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            self._emailDownloaded = dict?["Email"] as? String
            self.downloadImageUrl(onfirstnamedownloadComplete: { (status) in
                if status == true {
                        //download Image
                    let downloadimageURL: StorageReference = Storage.storage().reference(forURL: self._imageURLDownloaded!)
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
                                        if let imageData = UIImage(data: data!) {
                                            self.qrcodeimage.image = imageData
                                        }
                                    }
                                    
                                }
                            })
                        }
                    }
                }
            })
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }

    
    func downloadImageUrl(onfirstnamedownloadComplete: @escaping (_ status: Bool)->()) {
        let userRef = DataService.instance.REF_BASE
        let userID = Auth.auth().currentUser?.uid
        
        userRef.child("users").child(userID!).observeSingleEvent(of: .value) { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            let imageURL = dict?["imageURL"] as? String
            self._imageURLDownloaded = imageURL
            
            onfirstnamedownloadComplete(true)
        }
    }
    
    @IBAction func downloadQRCodePressed(_ sender: Any) {
        //Download QRCode
        let downloadimageURL: StorageReference = Storage.storage().reference(forURL: self._imageURLDownloaded!)
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
                            self.showAlertView(image: imageData!, data: data!)
                        }
                        
                    }
                })
            }
        }
    }
    
    func showAlertView(image: UIImage, data: Data) {
        let alertView = UIAlertController(title: "QRConnect", message: "QRCode has been downloaded", preferredStyle: .alert)
        
        //Add Image
        alertView.addImage(image: image)
        
        alertView.addAction(UIAlertAction(title: "Save to Photos", style: .default, handler: { (action) in
            self.saveToPhotosPressed(image: image)
        }))
        alertView.addAction(UIAlertAction(title: "Email", style: .default, handler: { (action) in
            self.emailPressed(data: data)
        }))
        
        alertView.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            //dismiss alertview
            alertView.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertView, animated: true, completion: nil)
        
    }
    
    func emailPressed(data: Data) {
        let composeemail = MFMailComposeViewController()
        composeemail.mailComposeDelegate = self
        composeemail.setToRecipients([self._emailDownloaded!])
        composeemail.setSubject("QRConnect - QR-Code")
        composeemail.setMessageBody("Hi, we are excited to see you. Hope you never lose your belongings again!", isHTML: false)
        composeemail.addAttachmentData(data, mimeType: "image/png", fileName: "QRCode")
        self.present(composeemail, animated: true, completion: nil)
        
    }
    
    func saveToPhotosPressed(image: UIImage) {
        
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                } else {
                    let alertview = UIAlertController(title: "QRConnect", message: "The app needs access to your photos to save the QRCode", preferredStyle: .alert)
                    alertview.addAction((UIAlertAction(title: "OK", style: .default, handler: nil)))
                    self.present(alertview, animated: true, completion: nil)
                    
                }
            })
        }
        else if photos == .authorized {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        else  {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            })
        }
    }
    

    
}
