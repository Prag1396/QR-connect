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
import PCLBlurEffectAlert

class QRCodeVC: UIViewController, MFMailComposeViewControllerDelegate, UIViewControllerPreviewingDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var unreadmessageindicator: UIImageView!
    @IBOutlet weak var qrcodeimage: imageStyle!
    
    private var _imageURLDownloaded: String? = nil
    private var _emailDownloaded: String? = nil
    private var _imagedata: Data? = nil
    var newValueofChildren: Int = 0
    var leftPanTriggered: Bool = false
    var rightPanTrigger: Bool = false
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
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan))
        edgePan.delegate = self
        edgePan.edges = .left
        edgePan.name = "Left"
        view.addGestureRecognizer(edgePan)
        
        let edgepan2 = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
        edgepan2.delegate = self
        edgepan2.edges = .right
        edgepan2.name = "Right"
        view.addGestureRecognizer(edgepan2)
        
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
    

    
    @objc func handleEdgePan(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        
        switch recognizer.state {
        case .began, .changed:
            if !leftPanTriggered {
                let threshold: CGFloat = 10
                let translation = abs(recognizer.translation(in: view).x)
                if translation >= threshold {
                    performAnimationLeft(recognizer: recognizer)
                    leftPanTriggered = true
                }
            }
        case .ended, .cancelled, .failed:
                self.leftPanTriggered = false
        default:
            break
        }
    }
    
    func performAnimationLeft(recognizer: UIScreenEdgePanGestureRecognizer) {
        print("here")
        if(recognizer.name == "Right") {
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let controllerToPresent = storyBoard.instantiateViewController(withIdentifier: "messagesvc") as? MessagesVC
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            view.window?.layer.add(transition, forKey: kCATransition)
            if let cp = controllerToPresent {
                self.present(cp, animated: false, completion: nil)
            }
            
            
        } else if(recognizer.name == "Left") {
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let controllerToPresent = storyBoard.instantiateViewController(withIdentifier: "settingsvc") as? SettingsVC
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            view.window?.layer.add(transition, forKey: kCATransition)
            if let cp = controllerToPresent {
                self.present(cp, animated: false, completion: nil)
            }
            
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

        let alert = PCLBlurEffectAlertController(title: "QRConnect", message: "Your personalised QRCode has been downloaded", effect: UIBlurEffect(style: .light), style: .alert)
        let img = image.scaleUIImageToSize(image: image, size: CGSize(width: 100, height: 100))
        alert.addImageView(with: img)
        alert.addAction(PCLBlurEffectAlertAction(title: "Save to Photos", style: .default, handler: { (action) in
            self.saveToPhotosPressed(image: image)
            self.view.alpha = 1.0

        }))
        alert.addAction(PCLBlurEffectAlertAction(title: "Email", style: .default, handler: { (actions) in
            self.emailPressed(data: data)
            self.view.alpha = 1.0

        }))
        alert.addAction(PCLBlurEffectAlertAction(title: "Cancel", style: .default, handler: { (action) in
            self.view.alpha = 1.0
        }))
        
        alert.configureAlert(alert: alert)
        alert.configure(buttonFont: [:], buttonTextColor: [.default: UIColor(red: 77/255, green: 255/255, blue: 158/255, alpha: 1.0) ], buttonDisableTextColor: [:])
        self.view.alpha = 0.7
        alert.show()
        
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
                    let alert = PCLBlurEffectAlertController(title: "Warning", message: "The app needs access to your photos to save the QRCode", effect: UIBlurEffect(style: .light), style: .alert)
                    alert.addAction(PCLBlurEffectAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.view.alpha = 1.0
                    }))
                    alert.configureAlert(alert: alert)
                    self.view.alpha = 0.7
                    alert.show()
                    
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
