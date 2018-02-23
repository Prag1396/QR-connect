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

class QRCodeVC: UIViewController, MFMailComposeViewControllerDelegate, UIViewControllerPreviewingDelegate {

    @IBOutlet weak var unreadmessageindicator: UIImageView!
    @IBOutlet weak var qrcodeimage: imageStyle!
    
    private var _imageURLDownloaded: String? = nil
    private var _emailDownloaded: String? = nil
    private var _imagedata: Data? = nil
    var newValueofChildren: Int = 0
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let loadingView: UIView = UIView()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setUpActivityIndicator()
        activityIndicator.startAnimating()
        unreadmessageindicator.isHidden = true
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: self.view)
        }
        
        self.checkforunreadmessages()
        
        if let tabArray: [UITabBarItem] = self.tabBarController?.tabBar.items {
        
            for item in tabArray {
                item.image = item.image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            }
        }
        
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
                                            self.activityIndicator.stopAnimating()
                                            self.loadingView.removeFromSuperview()
                                            self._imagedata = data!
                                            
                                        }
                                    }
                                    
                                }
                            })
                        }
                    }
                }
            })
        }

    }

    func setUpActivityIndicator() {

        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = self.view.center
        loadingView.backgroundColor = UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width/2, y: loadingView.frame.size.height/2)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        loadingView.addSubview(activityIndicator)
        view.addSubview(loadingView)
    }
    
    
    @IBAction func messagesbtnPressed(_ sender: Any) {
        self.writecounttoDatabase(newCount: self.newValueofChildren)
        self.unreadmessageindicator.isHidden = true
        
    }
    
    func checkforunreadmessages() {
        
        
        self.downloadcountfromDatabase(onCompleteObserving: { (count) in
            print("Current Value downloaded: \(count)")
            self.observeUnreadMessages {
                
                if(count != self.newValueofChildren && self.newValueofChildren > count) {
                    
                    print(self.newValueofChildren)
                    self.unreadmessageindicator.isHidden = false
                } else {
                    print("equal")
                    self.unreadmessageindicator.isHidden = true
                }
                
                print("New Value: \(self.newValueofChildren)")
            }
        })

    }
    
    func downloadcountfromDatabase(onCompleteObserving: @escaping (_ count: Int)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = DataService.instance.REF_USERMESSAGES
        userRef.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? NSDictionary else {
                return
            }
            if let count = dict["count"] as? Int {
                onCompleteObserving(count)
            } else {
                self.writecounttoDatabase(newCount: 0)
            }
        }
    }
    
    func writecounttoDatabase(newCount: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = DataService.instance.REF_USERMESSAGES.child(uid)
        userRef.updateChildValues(["count": newCount])
    }
    
    func observeUnreadMessages(onCompleteCounting: @escaping ()->()) {
        //count the number of messages recieved for current user
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let userRef = DataService.instance.REF_MESS
        userRef.observe(.childAdded) { (snapshot) in
            guard let dict = snapshot.value as? NSDictionary else {
                return
            }
            if let toID = dict["toID"] as? String {
                if toID == uid {
                    //increment counter
                    self.newValueofChildren = self.newValueofChildren + 1
                    onCompleteCounting()
                }
            }
            
        }
        
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let convertedLocation = view.convert(location, to: qrcodeimage)
        if qrcodeimage.bounds.contains(convertedLocation) {
            //present options
            print("here")
            let detailsVC = storyboard?.instantiateViewController(withIdentifier: "threedqr") as? QRCode3dVC
            DispatchQueue.main.async {
                if let imageData = UIImage(data: self._imagedata!) {
                    detailsVC?.qrcode3d.image = imageData
                    detailsVC?.imageData = imageData
 
                }
            }
            previewingContext.sourceRect = qrcodeimage.frame
            return detailsVC
        } else {
            return nil
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        showDetailViewController(viewControllerToCommit, sender: self)
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
        print("hrer")
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
