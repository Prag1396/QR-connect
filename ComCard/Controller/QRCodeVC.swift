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
import NVActivityIndicatorView

struct checkifLaunched {
    public static let userDefaultsQRVC = UserDefaults.standard
}

class QRCodeVC: UIViewController, MFMailComposeViewControllerDelegate, UIViewControllerPreviewingDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var unreadmessageindicator: UIImageView!
    @IBOutlet weak var qrcodeimage: imageStyle!
    @IBOutlet weak var downloadqrcodebtn: buttonStyle!
    @IBOutlet weak var messagetext: UILabel!
    @IBOutlet weak var hometitle: UILabel!
    @IBOutlet weak var qrModelImg: UIImageView!

    
    private var _imageURLDownloaded: String? = nil
    private var _emailDownloaded: String? = nil
    private var _imagedata: Data? = nil
    var newValueofChildren: Int = 0
    var panTriggered: Bool = false
    var testImage: UIImage?
    var activityIndicatorView: NVActivityIndicatorView?

    let loadingView: UIView = UIView()
    //let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.qrModelImg.isHidden = true
        self.checkIfLaunchedBefore()
        self.setUpActivityIndicator()
        activityIndicatorView?.startAnimating()
        unreadmessageindicator.isHidden = true
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: self.view)
        }
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan))
        edgePan.delegate = self
        edgePan.edges = .left
        if #available(iOS 11.0, *) {
            edgePan.name = "Left"
        } else {
            // Fallback on earlier versions
        }
        view.addGestureRecognizer(edgePan)
        
        let edgepan2 = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
        edgepan2.delegate = self
        edgepan2.edges = .right
        if #available(iOS 11.0, *) {
            edgepan2.name = "Right"
        } else {
            // Fallback on earlier versions
        }
        view.addGestureRecognizer(edgepan2)
        
        if let tabArray: [UITabBarItem] = self.tabBarController?.tabBar.items {
        
            for item in tabArray {
                item.image = item.image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            }
            
        }
        
        self.downloadQRCodeandEmail { (status, error, errmsg) in
            if error != nil {
                print(error?.localizedDescription ?? String())
                return
            }
            else if errmsg != nil {
                print(errmsg ?? String())
                return
            }
            
            self.convergeImages()
        }
        self.checkforunreadmessages()
    
        downloadqrcodebtn.isMultipleTouchEnabled = false
    }
    
    func convergeImages() {
        guard let mainImage = self.qrModelImg.image else {
            return
        }
        guard let overlayImage = self.qrcodeimage.image else {
            return
        }
        testImage = UIImage.combineWith(image1: mainImage, image2: overlayImage)
        
    }
    
    func downloadQRCodeandEmail(onComplete: @escaping (_ status: Bool, _ error: Error?, _ errmsg: String?)->()) {
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
                                    onComplete(false, error, nil)
                                } else {
                                    //Present sub view with the options of saving the image or emailing it
                                    DispatchQueue.main.async {
                                        if let imageData = UIImage(data: data!) {
                                            //overlap images
                                            
                                            self.qrModelImg.isHidden = false
                                            self.qrcodeimage.image = imageData
                                            self.activityIndicatorView?.stopAnimating()
                                            self.loadingView.removeFromSuperview()
                                            self._imagedata = data!
                                            onComplete(true, nil, nil)
                                            
                                        } else {
                                            onComplete(false, nil, nil)
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
    
    
    func checkIfLaunchedBefore() {
        if checkifLaunched.userDefaultsQRVC.bool(forKey: "hasLaunchedbefore") == true {
            DispatchQueue.main.async {
                self.hometitle.text = "Home"
            }

        } else {
            checkifLaunched.userDefaultsQRVC.set(true, forKey: "hasLaunchedbefore")
            checkifLaunched.userDefaultsQRVC.synchronize()
        }
    }
    

    
    @objc func handleEdgePan(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        
        switch recognizer.state {
        case .began, .changed:
            if !panTriggered {
                let threshold: CGFloat = 10
                let translation = abs(recognizer.translation(in: view).x)
                if translation >= threshold {
                    performAnimation(recognizer: recognizer)
                    panTriggered = true
                }
            }
        case .ended, .cancelled, .failed:
                self.panTriggered = false
        default:
            break
        }
    }
    
    func performAnimation(recognizer: UIScreenEdgePanGestureRecognizer) {
        if #available(iOS 11.0, *) {
            if(recognizer.name == "Right") {
                
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let controllerToPresent = storyBoard.instantiateViewController(withIdentifier: "messagesvc") as? MessagesVC
                let transition = CATransition()
                transition.duration = 0.23
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
                transition.duration = 0.23
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromLeft
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                view.window?.layer.add(transition, forKey: kCATransition)
                if let cp = controllerToPresent {
                    self.present(cp, animated: false, completion: nil)
                }
                
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func setUpActivityIndicator() {

        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = self.view.center
        loadingView.backgroundColor = UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        
        let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicatorView = NVActivityIndicatorView(frame:frame , type: .ballPulse, color: UIColor.white, padding: 0)
        activityIndicatorView?.center = CGPoint(x: loadingView.frame.size.width/2, y: loadingView.frame.size.height/2)
        loadingView.addSubview(activityIndicatorView!)
        self.view.addSubview(loadingView)
    }
    
    
    @IBAction func messagesbtnPressed(_ sender: Any) {
        self.unreadmessageindicator.isHidden = true
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let userRef = DataService.instance.REF_USERS.child(uid)
        userRef.updateChildValues(["unreadMessagesCounter": 0])
        
    }
    
    func checkforunreadmessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let userRef = DataService.instance.REF_USERS
        userRef.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? NSDictionary else {
                return
            }
            if let unreadMessagesCounter = dict["unreadMessagesCounter"] as? Int {
                if(unreadMessagesCounter != 0) {
                    self.unreadmessageindicator.isHidden = false
                } else {
                    self.unreadmessageindicator.isHidden = true
                }
            }
            
        }

    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let convertedLocation = view.convert(location, to: qrcodeimage)
        if qrcodeimage.bounds.contains(convertedLocation) {
            //present options
            let detailsVC = storyboard?.instantiateViewController(withIdentifier: "threedqr") as? QRCode3dVC
            DispatchQueue.main.async {
                if let imageData = UIImage(data: self._imagedata!), let testimg = self.testImage {
                    detailsVC?.qrcode3d.image = imageData
                    detailsVC?.imageData = imageData
                    detailsVC?.modalImage = testimg
                }
            }
            detailsVC?.preferredContentSize = CGSize(width: 179, height: 210)
            previewingContext.sourceRect = qrModelImg.frame
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

        guard let image = testImage else { return }
        let testimageData = UIImageJPEGRepresentation(image, 1.0) 
        
        if let image = self.testImage, let data = testimageData {
            self.showAlertView(image: image, data: data)
        }
    }
    
    func showAlertView(image: UIImage, data: Data) {

        let alert = PCLBlurEffectAlertController(title: "QRConnect", message: "Your personalised QRCode has been downloaded", effect: UIBlurEffect(style: .light), style: .alert)
        let img = image.resizeImage(image: image, newSize: CGSize(width: 100, height: 100))
        alert.addImageView(with: img)
        alert.addAction(PCLBlurEffectAlertAction(title: "Save to Photos", style: .default, handler: { (action) in
            print(image.size)
            self.saveToPhotosPressed(image: image)
            UIView.animate(withDuration: 0.5, animations: {
                self.view.alpha = 1.0
            })


        }))
        alert.addAction(PCLBlurEffectAlertAction(title: "Email", style: .default, handler: { (actions) in
            self.emailPressed(data: data)
            UIView.animate(withDuration: 0.5, animations: {
                self.view.alpha = 1.0
            })


        }))
        alert.addAction(PCLBlurEffectAlertAction(title: "Cancel", style: .default, handler: { (action) in
            UIView.animate(withDuration: 0.5, animations: {
                self.view.alpha = 1.0
            })

        }))
        
        alert.configureAlert(alert: alert)
        alert.configure(titleColor: UIColor(red: 77/255, green: 225/255, blue: 158/255, alpha: 1.0))
        alert.configure(buttonFont: [:], buttonTextColor: [.default: UIColor(red: 77/255, green: 255/255, blue: 158/255, alpha: 1.0) ], buttonDisableTextColor: [:])
        alert.configure(buttonBackgroundColor: UIColor.clear)
        alert.show()
        self.view.alpha = 0.7
        
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
                        UIView.animate(withDuration: 0.5, animations: {
                            self.view.alpha = 1.0
                        })
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
